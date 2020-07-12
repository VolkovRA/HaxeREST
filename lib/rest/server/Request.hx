package rest.server;

import rest.route.API;
import rest.route.Path;
import js.lib.Error;
import js.node.Buffer;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;
import haxe.DynamicAccess;

/**
 * Клиентский запрос.
 * 
 * Класс инкапсулирует свойства и методы для первичной
 * обработки входящего соединения. Экземпляры этого
 * класса создаются в `Server`. Один экземпляр `Request`
 * обрабатывает один http/s запрос.
 * 
 * п.с. Вы не должны самостоятельно создавать экземпляры
 * этого класса.
 */
@:allow(rest.server.Server)
class Request
{
    private var buffer:Array<Buffer>;

    /**
     * Создать обработчик входящего соединения.
     */
    private function new() {
    }

    /**
     * Инициализировать объект.
     * @param load Загрузить тело запроса.
     */
    private function init(load:Bool):Void {
        if (load) {
            msg.on('error', onError);
            msg.on('data', onData);
            msg.on('end', onEnd);
        }
        else {
            msg.pause();
            server.onRequestReady(this);
        }
    }

    /**
     * Сервер REST API, к которому относится данный запрос.
     * 
     * Не может быть `null`
     */
    public var server(default, null):Server;

    /**
     * Нативный объект `IncomingMessage` NodeJS для обработки запроса.
     * 
     * Не может быть `null`
     * 
     * @see https://nodejs.org/api/http.html#http_class_http_incomingmessage
     */
    public var msg(default, null):IncomingMessage;

    /**
     * Нативный объект `ServerResponse` NodeJS для обработки запроса.
     * 
     * Не может быть `null`
     * 
     * @see https://nodejs.org/api/http.html#http_class_http_serverresponse
     */
    public var res(default, null):ServerResponse;

    /**
     * Путь запрошенного ресурса, разбитый по слешам.
     * 
     * Пример:
     * ```
     * [""]; // Запрос в корень
     * ["users", "24"]; // Запрос: "users/24" или "users//24"
     * ```
     * 
     * *п.с. Этот массив возвращается методом: `Utils.readPath()`*
     * 
     * Не может быть `null`.
     */
    public var path(default, null):Path;

    /**
     * API Метод, к которому относится данный запрос.
     * - Если задан - содержит ссылку на описание метода.
     * - Если не задан - запрос не относится ни к одному методу. (Шальной)
     * 
     * По умолчанию: `null`
     */
    public var api(default, null):API = null;

    /**
     * Параметры запроса в URL. (То, что идёт после знака `?`)
     * 
     * Для получения этих параметров у данного метода должен быть
     * включен их разбор: `API.query=true`. Эти параметры не зависят
     * от типа запроса (GET, POST) и могут быть получены для любого
     * http глагола.
     * 
     * По умолчанию: `null`
     */
    public var query(default, null):DynamicAccess<String> = null;

    /**
     * Тело данных запроса, полученных от клиента.
     * - Формат данных зависит от указанного типа в: `API.bodyFormat`.
     * - По умолчанию тело данных равно `null` и не загружается, если
     *   не установлена его загрузка: `API.body=true`. Если загрузка
     *   установлена: `API.body=true`, то при передаче объекта в 
     *   обработчик метода, данные будут готовы к чтению.
     * 
     * По умолчанию: `null`
     */
    public var body:Dynamic = null;

    /**
     * Количество загруженных данных на данный момент. (Байт)
     * 
     * Содержит объём загруженных данных тела сообщения на
     * момент вызова. Может использоваться для отслеживания
     * прогресса загрузки.
     * 
     * По умолчанию: `0`
     */
    public var bytesLoaded(default, null):Int = 0;

    /**
     * Общий размер всего тела сообщения. (Байт)
     * 
     * Содержит число байт тела сообщения, которое указал клиент
     * в заголовках. Реальное количество байт может быть другим.
     * Клиент может не передать заголовок с размером, тогда
     * возвращаемое значение будет равно `0`.
     * 
     * По умолчанию: `0`
     */
    public var bytesTotal(get, never):Int;
    function get_bytesTotal():Int {
        return Utils.getBytesTotal(msg);
    }

    /**
     * Ошибка выполнения запроса.
     * 
     * Свойство содержит экземпляр ошибки, если не удалось выполнить
     * запрос. (Например, из за некорректного типа полученных данных)
     * 
     * По умолчанию: `null`
     */
    public var error:Error = null;

    /**
     * Произвольные, пользовательские данные.
     * 
     * Полезно для хранения любых данных. Объект никак не управляет
     * значением этого свойства и оно ни на что не влияет.
     * 
     * По умолчанию: `null`
     */
    public var userData:Dynamic = null;



    /////////////////
    //   СОБЫТИЯ   //
    /////////////////

    private function onData(data:Buffer):Void {
        if (buffer == null) {
            buffer = [data];
            bytesLoaded = data.length;
        }
        else {
            buffer.push(data);
            bytesLoaded += data.length;
        }
        
        // Ограничение размера тела сообщения:
        var limit = api==null?server.bodySizeDefault:Utils.nvl(api.bodySize, server.bodySizeDefault);
        if (limit > 0 && bytesLoaded > limit) {
            msg.off('error', onError);
            msg.off('data', onData);
            msg.off('end', onEnd);
            msg.pause();

            error = new Error("Payload client data too large: " + Utils.getBytesSize(bytesLoaded) + ", limit: " + Utils.getBytesSize(limit));
            buffer = null;

            server.send413(this);
        }
    }

    private function onError(err:Error):Void {
        msg.off('error', onError);
        msg.off('data', onData);
        msg.off('end', onEnd);

        error = err;
        buffer = null;

        server.send500(this);
    }

    private function onEnd():Void {
        msg.off('error', onError);
        msg.off('data', onData);
        msg.off('end', onEnd);

        // Интерпретация полученных данных:
        if (buffer != null) {
            if (api == null || api.bodyFormat == null) { // BodyFormat.TEXT
                body = Buffer.concat(buffer).toString();
                buffer = null;
            }
            else if (Utils.eq(api.bodyFormat, BodyFormat.QUERY)) {
                body = Utils.readQuery(Buffer.concat(buffer).toString());
                buffer = null;
            }
            else if (Utils.eq(api.bodyFormat, BodyFormat.JSON)) {
                try {
                    body = Global.JSON.parse(Buffer.concat(buffer).toString());
                    buffer = null;
                }
                catch (err:Dynamic) {
                    err.message = "Error to read JSON object\n" + Utils.str(err.message);
                    error = err;
                    buffer = null;
                    server.send400(this);
                    return;
                }
            }
            else if (Utils.eq(api.bodyFormat, BodyFormat.BINARY)) {
                body = Buffer.concat(buffer);
                buffer = null;
            }
            else { // BodyFormat.TEXT
                body = Buffer.concat(buffer).toString();
                buffer = null;
            }
        }

        server.onRequestReady(this);
    }
}