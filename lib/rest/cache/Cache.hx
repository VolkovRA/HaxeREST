package rest.cache;

import haxe.DynamicAccess;
import js.Node;
import js.Syntax;
import js.lib.Error;
import js.node.Buffer;
import js.node.Crypto;
import js.node.Fs;
import js.node.Path;
import js.node.Timers;
import js.node.Zlib;
import js.node.events.EventEmitter;
import js.node.fs.FSWatcher;
import js.node.fs.Stats;
import rest.mime.MimeTypeList;

/**
 * Кеш файлов.
 * 
 * Это отдельная, небольшая утилита для кеширования файлов операционной
 * системы в оперативной памяти приложения, для последующего их быстрого
 * извлечения. Использует сжатие gzip.
 * 
 * Эта библиотечка полезна для сервера с небольшим количеством статики,
 * что бы не читать файлы каждый раз из системы. Я решил включить эту
 * утилиту в пакет rest, что бы не создавать отдельных, мелких зависимостей.
 * Для реализации REST API применение этой библиотеки строго не обязательно,
 * вы можете читать и отдавать файлы напрямую из файловой системы.
 * 
 * Способ применения:
 *   1. Создайте экземпляр класса.
 *   2. Назначьте папку в свойстве `root`, содержимое которой будет кешироваться.
 *   3. Получите кешированные файлы методом: `get()`. 
 * 
 * События:
 * - `CacheEvent.FILE_ADD`      В кеш добавлен новый файл.
 * - `CacheEvent.FILE_REMOVE`   Из кеша удалён файл.
 * - `CacheEvent.FILE_UPDATE`   Файл в кеше обновлён.
 * - `CacheEvent.FILE_COMPRESS` Файл в кеше сжат.
 * - `CacheEvent.UPDATE_START`  Запущен цикл обновления файлов в кеше.
 * - `CacheEvent.UPDATE_END`    Цикл обновления кеша завершён.
 * - `CacheEvent.ERROR`         Ошибка кеша. (Приложение не падает)
 */
class Cache extends EventEmitter<Cache>
{
    /**
     * Тип используемого сжатия.
     * Это значение подходит для указания его в заголовках HTTP: `Content-Encoding: gzip`.
     */
    static public inline var COMPRESS_TYPE:String = "gzip";

    // Приват:
    private var files = new DynamicAccess<CacheFile>();
    private var watchers = new Array<FSWatcher>();
    private var timeoutID:Timeout = null;
    private var upd:Int = 0; // <-- Счётчик асинхронных вызовов для определения завершения кеширования цикла обновления.

    /**
     * Создать файловый кеш.
     * @param root Путь кешируемого файла или папки.
     */
    public function new(root:String = null) {
        super();
        this.root = root;
    }



    //////////////////
    //   СВОЙСТВА   //
    //////////////////

    /**
     * Путь кешируемого файла или папки.
     * - Вызов игнорируется, если указанное значение не отличается от текущего.
     * - При указании нового значения все кешированные файлы удаляются. События
     *   не вызываются. Обновление файлов начнётся на следующем тике.
     * - Указанное значение обрабатывается методом: `Path.normalize()` для
     *   приведения пути к корректному виду.
     * 
     * По умолчанию: `null` (Путь не указан)
     * 
     * @see Path.normalize: https://nodejs.org/api/path.html#path_path_normalize_path
     */
    public var root(default, set):String = null;
    function set_root(value:String):String {
        if (value == null) {
            if (root == null)
                return value;

            root = null;
            clear();
        }
        else {
            var v = Path.normalize(value);
            if (v == root)
                return value;

            root = v;
            clear();
        }

        return value;
    }

    /**
     * Количество файлов в кеше.
     * 
     * По умолчанию: `0`
     */
    public var count(default, null):Int = 0;

    /**
     * Счётчик циклов обновления кеша.
     * 
     * Это значение используется внутренней реализацией, но
     * может быть полезно для определения количества выполненных
     * обноволений за всё время.
     * 
     * По умолчанию: `0`
     */
    public var age(default, null):Int = 0;

    /**
     * Режим применения сжатия.
     * - Вызов игнорируется, если указанное значение не отличается от текущего.
     * - При указании нового значения все кешированные файлы удаляются. События
     *   не вызываются. Обновление файлов начнётся на следующем тике.
     * 
     * По умолчанию: `CompressMode.COMPRESS`
     */
    public var compress(default, set):CompressMode = CompressMode.COMPRESS;
    function set_compress(value:CompressMode):CompressMode {
        if (value == compress)
            return value;

        compress = value;
        clear();
        return value;
    }



    ////////////////
    //   МЕТОДЫ   //
    ////////////////

    /**
     * Получить кешированный файл.
     * 
     * Возвращает данные файла или `null`, если такого файла нет в кеше.
     * 
     * @param name Имя файла, включая его относительный путь от корня кеширования.
     */
    public inline function get(name:String):CacheFile {
        return files[name];
    }

    /**
     * Подсчитать общий объём всех файлов в кеше. (Байт)
     * 
     * Возвращает количество байт, занимаемых всем файлами
     * в кеше на момент вызова.
     * 
     * @return Объём кеша. (Байт)
     */
    public function getSize():Int {
        var key:String = null;
        var bytes = 0;
        Syntax.code('for ({0} in {1}) {', key, files); // for in
            var file = files[key];
            if (file != null && file.data != null)
                bytes += file.data.length;
        Syntax.code('}'); // for end
        return bytes;
    }

    /**
     * Очистить кеш.
     * - Удаляет все файлы, находящиеся в кеше.
     * - События не вызываются.
     * - Если задан путь кеширования (`root` не `null`), планирует обновление кеша на следующем тике.
     */
    public function clear():Void {
        files = new DynamicAccess<CacheFile>();
        count = 0;
        age ++;

        // Удаляем все старые слушатели:
        var i = watchers.length;
        while (i-- > 0) {
            watchers[i].removeListener(FSWatcherEvent.Change, onWatcherChange);
            watchers[i].removeListener(FSWatcherEvent.Error, onWatcherError);
            watchers[i].close();
        }
        watchers = new Array<FSWatcher>();

        // Цикл обновления:
        if (root == null) {
            if (timeoutID != null) {
                Node.clearTimeout(timeoutID);
                timeoutID = null;
            }
        }
        else {
            if (timeoutID == null)
                timeoutID = Node.setTimeout(onTimeout, 0);
        }
    }
    
    /**
     * Получить копию списка всех файлов в кеше.
     * 
     * Создаёт и возвращает новый массив, содержащий все
     * файлы в кеше.
     * 
     * Не может быть `null`.
     * 
     * @return Список файлов в кеше.
     */
    public function getFiles():Array<CacheFile> {
        var arr:Array<CacheFile> = Utils.createArray(count);
        var key:String = null;
        var i = 0;

        Syntax.code('for ({0} in {1}) {', key, files); // for in
            arr[i++] = files[key];
        Syntax.code('}'); // for end

        return arr;
    }

    // ЛИСТЕНЕРЫ
    private function onWatcherError(err:Error):Void {
        if (timeoutID == null)
            timeoutID = Node.setTimeout(onTimeout, 500);

        err.message = "Error listening of file system changes\n" + err.message;
        emit(CacheEvent.ERROR, err);
    }
    private function onWatcherChange(type:FSWatcherChangeType, path:FsPath):Void {
        if (timeoutID == null)
            timeoutID = Node.setTimeout(onTimeout, 500);
    }
    private function onTimeout():Void {
        timeoutID = null;
        upd = 0;
        age ++;
        
        // Удаляем все старые слушатели:
        var i = watchers.length;
        while (i-- > 0) {
            watchers[i].removeListener(FSWatcherEvent.Change, onWatcherChange);
            watchers[i].removeListener(FSWatcherEvent.Error, onWatcherError);
            watchers[i].close();
        }
        watchers = new Array<FSWatcher>();
        
        // Событие:
        emit(CacheEvent.UPDATE_START);

        // Запускаем рекурсивное кеширование:
        updateCache(root, age);
    }
    private function checkComplete(cage:Int):Void {
        upd --;

        // Каждый асинхронный вызов перед запуском увеличивает счётчик upd и уменьшает при завершении на 1:
        // trace("Асинхронных вызовов: " + upd + ", age: " + age); // <-- Использовать для проверки корректности работы счётчика асинхронных вызовов

        // Кеширование завершено:
        if (upd == 0) {
            var arr = new Array<CacheFile>();

            // Удаление старых файлов из кеша:
            for (file in files) {
                if (file.age == age)
                    continue;
                
                Utils.delete(files[file.path]);
                arr.push(file);
                count --;
            }

            // События:
            var i = arr.length;
            while (i > 0 && age == cage)
                emit(CacheEvent.FILE_REMOVE, arr[--i]);

            // Завершение:
            if (age == cage)
                emit(CacheEvent.UPDATE_END);
        }
    }

    // ПРИВАТ
    private function updateCache(path:String, cage:Int):Void {
        upd ++; // <-- Новый асинхронный вызов
        Fs.stat(path, function(err:Error, stats:Stats):Void {
            
            // Асинхронный вызов устарел:
            if (cage != age)
                return;
            
            // Если путь был удалён или нет прав - просто выводим предупреждение:
            if (err != null) {
                err.message = "Error reading file system\n" + err.message;
                emit(CacheEvent.ERROR, err);
                checkComplete(cage);
                return;
            }
            
            // Файл:
            if (stats.isFile()) {
                upd ++; // <-- Новый асинхронный вызов
                Fs.readFile(path, function(err:Error, buffer:Buffer):Void {
                    
                    // Асинхронный вызов устарел:
                    if (cage != age)
                        return;
                    
                    // Ошибка:
                    if (err != null) {
                        err.message = "Error reading file\n" + err.message;
                        emit(CacheEvent.ERROR, err);
                        checkComplete(cage);
                        return;
                    }
                    
                    // Параметры:
                    var name = path.substr(root.length + Path.sep.length);
                    var hash = Crypto.createHash(CryptoAlgorithm.MD5).update(buffer).digest("hex");
                    var type = MimeTypeList.get(Path.extname(path));
                    
                    // Чтение файла:
                    var file = files[name];
                    if (file == null) {
                        
                        // Файла с таким именем нет в кеше:
                        file = {
                            path: name,
                            mime: type,
                            hash: hash,
                            age: cage,
                            data: buffer,
                            isCompressed: false,
                        };
                        files[name] = file;
                        count ++;
                        
                        // Асинхронное сжатие:
                        if (compress == CompressMode.COMPRESS_ALL || (compress == CompressMode.COMPRESS && (type == null || !type.isCompressed))) {
                            upd ++; // <-- Новый асинхронный вызов
                            Zlib.gzip(buffer, function(err:Error, buffer:Buffer):Void {
                                
                                // Асинхронный вызов устарел:
                                if (cage != age)
                                    return;
                                
                                // Ошибка:
                                if (err != null) {
                                    err.message = "File Compression Error\n" + err.message;
                                    emit(CacheEvent.ERROR, err);
                                    checkComplete(cage);
                                    return;
                                }
                                
                                file.data = buffer;
                                file.isCompressed = true;
                                emit(CacheEvent.FILE_COMPRESS, file);
                                checkComplete(cage);
                            });
                        }

                        // Добавлен новый файл:
                        emit(CacheEvent.FILE_ADD, file);
                    }
                    else {
                        
                        // Файл с таким именем уже содержится в кеше:
                        file.age = cage;
                        
                        // Файл не изменился:
                        if (hash == file.hash) {
                            checkComplete(cage);
                            return;
                        }
                        
                        // Файл изменился, обновляем:
                        file.hash = hash;
                        file.data = buffer;
                        file.isCompressed = false;
                        
                        // Асинхронное сжатие:
                        if (compress == CompressMode.COMPRESS_ALL || (compress == CompressMode.COMPRESS && (type == null || !type.isCompressed))) {
                            upd ++; // <-- Новый асинхронный вызов
                            Zlib.gzip(buffer, function(err:Error, buffer:Buffer):Void {
                                
                                // Асинхронный вызов устарел:
                                if (cage != age)
                                    return;
                                
                                // Ошибка:
                                if (err != null) {
                                    err.message = "File Compression Error\n" + err.message;
                                    emit(CacheEvent.ERROR, err);
                                    checkComplete(cage);
                                    return;
                                }
                                
                                file.data = buffer;
                                file.isCompressed = true;
                                emit(CacheEvent.FILE_COMPRESS, file);
                                checkComplete(cage);
                            });
                        }

                        // Обновлён файл:
                        emit(CacheEvent.FILE_UPDATE, file);
                    }
                    
                    // Асинхронный вызов завершён: Fs.readFile
                    checkComplete(cage);
                });
                
                // Асинхронный вызов завершён: Fs.stat
                checkComplete(cage);
                return;
            }
            
            // Папка:
            if (stats.isDirectory()) {
                upd ++; // <-- Новый асинхронный вызов
                Fs.readdir(path, function(err:Error, arr:Array<String>):Void {
                    
                    // Асинхронный вызов устарел:
                    if (cage != age)
                        return;
                    
                    // Ошибка:
                    if (err != null) {
                        err.message = "Folder read error\n" + err.message;
                        emit(CacheEvent.ERROR, err);
                        checkComplete(cage);
                        return;
                    }
                    
                    // Слушаем изменения в этой папке, что бы автоматически обновлять кеш:
                    try {
                        var watcher = Fs.watch(path);
                        watcher.addListener(FSWatcherEvent.Change, onWatcherChange);
                        watcher.addListener(FSWatcherEvent.Error, onWatcherError);
                        watchers.push(watcher);
                    }
                    catch (err:Error) {
                        err.message = "Failed to add listening of directory changes:\n" + err.message;
                        emit(CacheEvent.ERROR, err);
                        checkComplete(cage);
                        return;
                    }
                    
                    // Обрабатываем содержимое папки:
                    var l = arr.length;
                    while (l-- > 0)
                        updateCache(path + Path.sep + arr[l], cage);
                    
                    // Асинхронный вызов завершён: Fs.readdir
                    checkComplete(cage);
                });
                
                // Асинхронный вызов завершён: Fs.stat
                checkComplete(cage);
                return;
            }
            
            // Асинхронный вызов завершён: Fs.stat
            checkComplete(cage);
        });
    }
}