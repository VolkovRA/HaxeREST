package rest;

import js.Syntax;
import js.node.http.IncomingMessage;
import rest.route.Path;
import haxe.DynamicAccess;

/**
 * Вспомогательные утилиты.
 */
@:dce
class Utils 
{
    /**
     * Декодировать унифицированный идентификатор ресурса (URI), созданный
     * при помощи метода `encodeURI()` или другой подобной процедуры.
     * 
     * @param uri Полный закодированный унифицированный идентификатор ресурса.
     * @return Новая строка, представляющая собой незакодированную версию данного
     *         унифицированного идентификатора ресурса.
     * @see Документация: https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/decodeURI
     */
    static public inline function decodeURI(uri:String):String {
        return Syntax.code("decodeURI({0})", uri);
    }

    /**
     * Кодировать универсальный идентификатор ресурса (URI).
     * 
     * Замещает некоторые символы на одну, две, три или четыре управляющие
     * последовательности, представляющие UTF-8 кодировку символа (четыре
     * управляющие последовательности будут использованы только для символов,
     * состоящих из двух «суррогатных» символов).
     * 
     * @param uri Полный URI.
     * @return Новая строка, представляющая собой строку-параметр, закодированную
     *         в виде универсального идентификатора ресурса (URI).
     * @see Документация: https://developer.mozilla.org/ru/docs/Web/JavaScript/Reference/Global_Objects/encodeURI
     */
    static public inline function encodeURI(uri:String):String {
        return Syntax.code("encodeURI({0})", uri);
    }

    /**
     * Создать обычный JavaScript массив заданной длины.
     * 
     * По сути, является аналогом для использования конструктора: `new Vector(length)`.
     * Полезен для разового выделения памяти нужной длины.
     * 
     * @param length Длина массива.
     * @return Массив.
     */
    public static inline function createArray(length:Int):Dynamic {
        return Syntax.code('new Array({0})', length);
    }

    /**
     * Привести значение к `String`.
     * Быстрая, нативная реализация JavaScript.
     * @param v Значение.
     * @return Строковое представление.
     */
    public static inline function str(v:Dynamic):String {
        return Syntax.code("({0} + '')", v);
    }

    /**
     * Удалить свойство.
     * Генерирует JS код: `delete obj.property`.
     * @param property Удаляемое свойство.
     */
    public static inline function delete(property:Dynamic):Void {
        Syntax.code("delete {0}", property);
    }

    /**
     * Получить значение свойства с проверкой на `null`.
     * 
     * Возвращает значение `def`, если свойство `prop` равно `null`, `undefined` или вовсе не определено.
     * 
     * Пример:
     * ```
     * var opt = { x:12, s:"Hello!" };
     * trace(Utils.nvl(opt.x, 0)); // 12
     * trace(Utils.nvl(opt.s, "")); // "Hello!"
     * trace(Utils.nvl(opt.y, 0)); // 0
     * ```
     * @param prop Свойство.
     * @param def Значение по умолчанию.
     * @return Значение свойства.
     */
    public static inline function nvl<T>(prop:T, def:T):T {
        return Syntax.code('({0} == null ? {1} : {0})', prop, def);
    }

    /**
     * Строговое равенство. (`===`).
     * 
     * Возможность использовать в Haxe чуть более быстрое сравнение JavaScript без авто-приведения типов.
     * Генерирует оптимальный JS код и встраивается в точку вызова.
     * 
     * @param v1 Значение 1.
     * @param v2 Значение 2.
     * @return Результат сравнения.
     */
    static public inline function eq(v1:Dynamic, v2:Dynamic):Bool {
        return Syntax.code('({0} === {1})', v1, v2);
    }

    /**
     * Нативная JavaScript реализация `parseInt()`.
     * 
     * Функция принимает строку в качестве аргумента и возвращает целое число в
     * соответствии с указанным основанием системы счисления.
     * 
     * @param v     Значение, которое необходимо проинтерпретировать. Если значение параметра
     *              не принадлежит строковому типу, оно преобразуется в него (с помощью абстрактной операции ToString).
     *              Пробелы в начале строки не учитываются.
     * 
     * @param base  Целое число в диапазоне между `2` и `36`, представляющее собой основание системы
     *              счисления числовой строки string, описанной выше. В основном пользователи используют
     *              десятичную систему счисления и указывают `10`. Всегда указывайте этот параметр,
     *              чтобы исключить ошибки считывания и гарантировать корректность исполнения и предсказуемость
     *              результата. Когда основание системы счисления не указано, разные реализации могут
     *              возвращать разные результаты.
     * 
     * @return      Целое число, полученное парсингом (разбором и интерпретацией) переданной строки.
     *              Если первый символ не получилось сконвертировать в число, то возвращается `NaN`. 
     */
    public static inline function parseInt(v:Dynamic, base:Int):Int {
        return Syntax.code('parseInt({0}, {1})', v, base);
    }

    /**
     * Получить строковое представление объёма информации.
     * Возвращает строковое описание количества байт, кб, мб и т.д.
     * @param	length Объём информации. (Байт)
     * @return	Строковое представление.
     */
    static public function getBytesSize(length:Int):String {

        // Таблица измерения количества информации:
        // https://ru.wikipedia.org/wiki/%D0%9C%D0%B5%D0%B3%D0%B0%D0%B1%D0%B0%D0%B9%D1%82
        // 	
        // +------------------------------+
        // |        ГОСТ 8.417—2002       |            
        // | Название Обозначение Степень |	
        // +------------------------------+
        // | байт        Б         10^0   |
        // | килобайт    Кбайт     10^3   |
        // | мегабайт    Мбайт     10^6   |
        // | гигабайт    Гбайт     10^9   |
        // | терабайт    Тбайт     10^12  |
        // | петабайт    Пбайт     10^15  |
        // | эксабайт    Эбайт     10^18  |
        // | зеттабайт   Збайт     10^21  |
        // | йоттабайт   Ибайт     10^24  |
        // +------------------------------+

        if (length < 1e3)		return length + " byte";
        if (length < 1e6)		return untyped Math.trunc(length / 1e1) / 1e2 + " KB";
        if (length < 1e9)		return untyped Math.trunc(length / 1e4) / 1e2 + " MB";
        if (length < 1e12)		return untyped Math.trunc(length / 1e7) / 1e2 + " GB";
        if (length < 1e15)		return untyped Math.trunc(length / 1e10) / 1e2 + " TB";
        if (length < 1e18)		return untyped Math.trunc(length / 1e13) / 1e2 + " PB";
        if (length < 1e21)		return untyped Math.trunc(length / 1e16) / 1e2 + " EB";
        if (length < 1e24)		return untyped Math.trunc(length / 1e19) / 1e2 + " ZB";

        return untyped Math.trunc(length / 1e22) / 1e2 + " YB";
    }

    /**
     * Прочитать путь метода API.
     * 
     * Этот метод используется для разбора входящего URL на
     * состовляющие его части и далнейшей обработки сервером.
     * 
     * Результат вызова не может быть `null`.
     * 
     * @param url URL Адрес.
     * @return Путь метода API.
     */
    static public function readPath(url:String):Path {
        if (url == null)
            return [''];

        // Удаляем параметры запроса и якорь, разбиваем путь:
        var index = url.indexOf('?');
        var path:Path;
        if (index == -1) {
            index = url.indexOf('#');
            if (index == -1)
                path = url.split('/');
            else
                path = url.substring(0, index).split('/');
        }
        else {
            path = url.substring(0, index).split('/');
        }

        // Удаляем пустоты '' и декодируем адрес в нормальный:
        index = 0;
        var i = 0;
        var len = path.length;
        while (i < len) {
            if (path[i] == '') {
                i ++;
                continue;
            }

            path[index++] = Utils.decodeURI(path[i++]);
        }
        path.resize(index);

        // Массив не может быть пустым:
        if (path.length == 0)
            return [''];
        
        return path;
    }

    /**
     * Прочитать поисковые параметры из URL адреса.
     * 
     * Этот метод используется для разбора входящего URL и
     * выделения из него поисковых параметров запроса.
     * (Того, что идёт после символа `?` и до `#`)
     * 
     * Результат вызова не может быть `null`.
     * 
     * @param url URL Адрес.
     * @return Параметры запроса из URL.
     */
    static public function readQueryFromURL(url:String):DynamicAccess<String> {
        if (url == null)
            return {};
        
        var index = url.indexOf('?');
        if (index == -1)
            return {};

        var index2 = url.indexOf('#', index);
        if (index2 == -1)
            return readQuery(url.substring(index+1));
        else
            return readQuery(url.substring(index+1, index2));
    }

    /**
     * Прочитать поисковые параметры.
     * 
     * Этот метод используется для разбора входящего URL и
     * выделения из него поисковых параметров запроса.
     * (Того, что идёт после символа `?` и до `#`)
     * 
     * Результат вызова не может быть `null`.
     * 
     * @param query Строка с поисковыми параметрами, разделёнными символом `&`.
     * @return Параметры запроса.
     */
    static public function readQuery(query:String):DynamicAccess<String> {
        if (query == null)
            return {};
        
        var map:DynamicAccess<String> = {};
        var arr = query.split('&');
        var i = 0;
        var len = arr.length;
        while (i < len) {
            var s = arr[i++];
            if (Utils.eq(s, ''))
                continue;

            var index = s.indexOf('=');
            if (Utils.eq(index, -1))
                map[Utils.decodeURI(s)] = null; // "v" -> { v:null }
            else if (Utils.eq(index, s.length-1))
                map[Utils.decodeURI(s.substring(0, index))] = null; // "v=" -> { v:null }
            else
                map[Utils.decodeURI(s.substring(0, index))] = Utils.decodeURI(s.substring(index+1)); // "v=1" -> { v:1 }
        }

        return map;
    }

    /**
     * Получить размер тела входящего запроса. (Байт)
     * 
     * Возвращает число байт тела сообщения, которое указал клиент
     * в заголовках. Реальное количество байт может быть другим.
     * Клиент может не передать заголовок с размером, тогда это
     * значение будет равно `0`.
     * 
     * @param msg Входящий запрос.
     * @return Число байт тела входящего запроса.
     */
    static public function getBytesTotal(msg:IncomingMessage):Int {
        if (msg.headers == null)
            return 0;

        var v = msg.headers["content-length"];
        if (v == null)
            return 0;

        return parseInt(v, 10);
    }
}