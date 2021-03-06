package rest.cache;

import js.node.Buffer;
import rest.mime.MimeType;

/**
 * Кешированный файл.
 * 
 * Кешированные файлы находятся в ОЗУ для максимально быстрой отправки
 * клиенту при их запросе. Все файлы в памяти сжимаются gzip, если их
 * формат не предполагает сжатия. (Не сжимаются: JPG, PNG ...)
 */
typedef CacheFile =
{
    /**
     * Путь файла относительно корня кешированной папки.
     * 
     * Пример: `favicon.ico` или `css/styles.css`.
     * 
     * Не может быть `null`
     */
    var path:String;
    
    /**
     * MIME Тип файла.
     * 
     * Может быть `null`, если тип файла не определён.
     */
    var mime:MimeType;
    
    /**
     * Содержимое файла.
     * 
     * Смотрите флаг `isCompressed` для определения того,
     * сжат файл или нет.
     * 
     * Может быть `null`
     */
    var data:Buffer;
    
    /**
     * Содержимое файла сжато. (gzip)
     * - Если `true`, то исходные данные файла в поле
     *   `data` находятся в сжатом состоянии.
     * - Сразу после загрузки файла из файловой системы,
     *   файл находится в несжатом виде и сжимается спустя
     *   некоторое время. (Асинхронное сжатие)
     * 
     * По умолчанию: `false`
     */
    var isCompressed:Bool;
    
    /**
     * Хеш подпись оригинального файла. (Не сжатого)
     * 
     * Используется внутренней реализацией для определения
     * наличия изменений в новом файле. Если подписи
     * кешированного и локального файла в системе не совпадают,
     * загружается новая версия файла для раздачи клиентам. 
     * 
     * Не может быть `null`
     */
    var hash:String;
    
    /**
     * Возраст файла.
     * 
     * Используется для удаления устаревших файлов из кеша.
     * Представляет номер цикла обновления кеша, в котором
     * был добавлен/проверен этот файл.
     * 
     * Это значение используется внутренней реализацией, вы
     * не должны его изменять.
     * 
     * Не может быть `null`
     */
    var age:Int;
}