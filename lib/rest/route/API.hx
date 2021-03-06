package rest.route;

import rest.server.BodyFormat;
import rest.server.Request;
import js.node.http.Method;

/**
 * REST API Метод.
 * 
 * Объект описывает вызываемый метод и некоторые его
 * индивидуальные свойства.
 * 
 * *Очень хотелось использовать имя класса Method, но оно уже занято.*
 */
typedef API =
{
    /**
     * URL Адрес этого метода REST API. (Относительно корня сайта)
     * 
     * Примеры:
     * - `users`
     * - `users/progress`
     * - `orders/cancel`
     * 
     * Не может быть `null`
     */
    var url:String;

    /**
     * HTTP Глагол этого метода API. (GET, POST, ...)
     * 
     * Не может быть `null`
     */
    var method:Method;

    /**
     * Обработчик вызова метода API.
     * 
     * Не может быть `null`
     */
    var callback:Request->Void;

    /**
     * Выполнять разбор параметров в URL.
     * 
     * Если задано `true`, будет производиться разбор параметров,
     * переданных в URL. (То, что идёт после знака `?`). Это
     * работает для любого типа запроса, не только GET. 
     * 
     * См. свойство: `Request.query`.
     * 
     * По умолчанию: `false` (Не выполнять разбор)
     */
    @:optional var query:Bool;

    /**
     * Загружать тело сообщения, переданного клиентом, перед вызовом метода API.
     * 
     * Применение:
     * - Если `true` - Запрос будет ожидать полного получения тела сообщения
     *   перед вызовом метода API `callback`. Полученные данные будут содержаться
     *   в `Request.body`. Если во время загрузки или чтения данных происходит
     *   ошибка, метод API не вызывается и запрос завершается одной из ошибок:
     *   `Server.send400`, `Server.send500` и т.д.
     * - Если `false` - Запрос будет передан методу API сразу после получения
     *   и разбора его URL. Обратите внимание, что в этом случае сокет входящего
     *   соединения ставится на паузу (`IncomingMessage.pause()`) для исключения
     *   получения ненужных данных. Тело сообщения `Request.body` в этом случае
     *   всегда равно `null`.
     * 
     * Эта опция может быть полезна для POST запросов, принимающих любые,
     * произвольные, пользовательские данные. Это свойство не влияет на параметры
     * переданные в URL: `Request.query`. 
     * 
     * По умолчанию: `false` (Тело запроса клиента игнорируется)
     */
    @:optional var body:Bool;

    /**
     * Максимальный объём принимаемых данных этим методом. (Байт)
     * - Это свойство используется только с `body=true`.
     * - Если объём не указан, используется значение по умолчанию: `Server.bodySizeDefault`.
     * - Если указанное значение меньше или равно `0` - ограничение на размер принимаемых данных не действует.
     * 
     * Если объём тела принимаемого запроса превысит это значение,
     * запрос будет немедленно закрыт с передачей статуса:
     * `413 Payload Too Large`. В этом случае апи метод `callback`
     * не вызывается.
     * 
     * По умолчанию: `Server.bodySizeDefault`
     */
    @:optional var bodySize:Int;

    /**
     * Тип получаемых данных от клиента.
     * 
     * Это свойство используется для способа интерпретации полученных
     * от клиента данных в теле запроса: `Request.body`.
     * - Это свойство используется только с `body=true`.
     * - Если не указано, используется значение по умолчанию: `BodyFormat.TEXT` (Текстовые данные)
     * 
     * По умолчанию: `BodyFormat.TEXT` (Текстовые данные)
     */
    @:optional var bodyFormat:BodyFormat;
}