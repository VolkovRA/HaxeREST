package rest.server;

import js.node.Path;
import rest.route.Route;
import rest.cache.Cache;
import rest.headers.HeaderName;
import rest.headers.CacheControl;
import rest.headers.ContentType;
import js.lib.Error;
import js.node.Http;
import js.node.Https;
import js.node.events.EventEmitter;
import js.node.http.Method;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;
import js.node.net.Socket;

/**
 * Сервер REST API.
 * 
 * 1. Одновременно может быть запущен только http или https web сервер.
 * 2. Для запуска на обеих протоколах создайте второй экземпляр.
 * 3. Каждый экземпляр `Server` является **одноразовым** и не может быть
 *    повторного использован для запуска. (Из-за особенностей API NodeJS)
 * 
 * События:
 * - `ServerEvent.REQUEST` Получен новый запрос.
 * - `ServerEvent.ONLINE` Сервер API запущен.
 * - `ServerEvent.OFFLINE` Сервер API отключен.
 * - `ServerEvent.START_ERROR` Ошибка запуска сервера API.
 */
@:allow(rest.server.Request)
class Server extends EventEmitter<Server>
{
    static private inline var STATE_OFFLINE     = 0; // Выключен.
    static private inline var STATE_STARTING    = 1; // Запускается.
    static private inline var STATE_ONLINE      = 2; // Запущен.
    static private inline var STATE_CLOSING     = 3; // Выключается.
    static private inline var STATE_CLOSED      = 4; // Выключен навсегда.

    private var srv:Dynamic = null;
    private var state:Int = STATE_OFFLINE;

    /**
     * Создать сервер REST API.
     */
    public function new() {
        super();
    }



    //////////////////
    //   СВОЙСТВА   //
    //////////////////

    /**
     * Сервер запущен.
     * - Если `true` - сервер запущен и готов принимать входящие соединения.
     * - Если `false` - сервер не запущен или не готов принимать входящие соединения, если закрывается.
     * 
     * По умолчанию: `false`
     */
    public var online(get, never):Bool;
    inline function get_online():Bool {
        return state == STATE_ONLINE;
    }

    /**
     * Карта методов API.
     * 
     * Перед запуском сервера вы должны заполнить методы API,
     * которые будут вызываться в ответ на входящие соединения.
     * 
     * По умолчанию: `null`
     */
    public var route:Route = null;

    /**
     * Статический контент для раздачи. (Статика)
     * 
     * Сервер может автоматически раздавать статику, если входящий
     * запрос не попадает ни под один зарегистрированный метод API.
     * 
     * По умолчанию: `null` (Статика не раздаётся)
     */
    public var content:Cache = null;

    /**
     * Флаг типа запуска сервера.
     *   - Если `true` - сервер работает по безопасному, https соединению.
     *   - Если `false` - сервер работает по обычному http соединению.
     *   - Если `null` - сервер не запущен.
     * 
     * По умолчанию: `null`
     */
    public var isHttps(default, null):Bool = null;

    /**
     * Максимальный размер получаемых данных в теле запроса. (Байт)
     * 
     * Это значение используется для входящих запросов по умолчанию, если:
     *   - Метод использует загрузку тела запроса: `API.body=true`
     *   - У метода не указан лимит на размер тела запроса: `API.bodySize=null`.
     * 
     * Значение меньше или равное `0` отключает лимит на размер тела запроса.
     * 
     * По умолчанию: `1000000` (1 Мегабайт)
     */
    public var bodySizeDefault:Int = 1000000;

    /**
     * Имя сервера, отправляемое в загаловках ответа.
     * 
     * По умолчанию: `Haxe REST API (NodeJS)`
     */
    public var name:String = "Haxe REST API (NodeJS)";

    /**
     * Имя индексного файла.
     * 
     * Используется для раздачи статики, когда запрос приходит
     * в корень каталога или сайта. Если каталог или сайт содержит
     * файл с указанным именем, он возвращается клиенту.
     * 
     * **Регистр важен.**
     * 
     * По умолчанию: 'index.html'
     */
    public var indexFile:String = "index.html";

    /**
     * Значение заголовка `Cache-Control` для **статического** контента.
     * 
     * Смотрите документацию по возможным значениям:
     * https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
     * 
     * По умолчанию: `120` секунд. (2 минуты)
     */
    public var cacheControl:String = "max-age=120";



    ////////////////
    //   МЕТОДЫ   //
    ////////////////

    /**
     * Запустить HTTP сервер REST API.
     * @param params Параметры запуска.
     */
     public function startHttp(params:ServerHttpParams):Void {
        if (state > STATE_OFFLINE) {
            emit(ServerEvent.START_ERROR, new Error("This Server instance was already running"));
            return;
        }

        state = STATE_STARTING;

        try {
            var http = Http.createServer();
            http.timeout = Utils.nvl(params.timeout, 10000);
            http.maxHeadersCount = Utils.nvl(params.maxHeadersCount, 50);
            http.on("request", onRequest);
            http.on("clientError", onClientError);
            http.on("close", onClosed);
            http.on("error", onError); //<-- Недокументированное событие, можно словить при попытке запуска на занятом порту!
            http.listen(params.port, params.host, onStart);
            srv = http;
            isHttps = false;
        }
        catch (err:Error) {
            state = STATE_CLOSED;
            err.message = "Error start http rest api server\n" + err.message;
            emit(ServerEvent.START_ERROR, err);
        }
    }

    /**
     * Запустить HTTPS сервер REST API.
     * @param params Параметры запуска.
     */
    public function startHttps(params:ServerHttpsParams):Void {
        if (state > STATE_OFFLINE) {
            emit(ServerEvent.START_ERROR, new Error("This Server instance was already running"));
            return;
        }

        state = STATE_STARTING;

        try {
            var https = Https.createServer(params.ssl);
            https.timeout = Utils.nvl(params.timeout, 10000);
            https.maxHeadersCount = Utils.nvl(params.maxHeadersCount, 50);
            https.on("request", onRequest);
            https.on("clientError", onClientError);
            https.on("close", onClosed);
            https.on("error", onError); //<-- Недокументированное событие, можно словить при попытке запуска на занятом порту!
            https.listen(params.port, params.host, onStart);
            srv = https;
            isHttps = true;
        }
        catch (err:Error) {
            state = STATE_CLOSED;
            err.message = "Error start https rest api server\n" + err.message;
            emit(ServerEvent.START_ERROR, err);
        }
    }

    /**
     * Закрыть сервер.
     * - Вызов игнорируется, если сервер не был запущен или уже остановлен.
     * - Этот вызов асинхронный, ждите событие: `ServerEvent.OFFLINE`.
     * - Этот вызов запрещает принимать новые соединения, но ожидает
     *   завершения обработки уже открытых.
     */
    public function close():Void {
        if (state == STATE_STARTING) {
            state = STATE_CLOSING; // <-- Сможем закрыть только после запуска!
            return;
        }
        if (state == STATE_ONLINE) {
            state = STATE_CLOSING;
            srv.close(onClosed);
            emit(ServerEvent.OFFLINE, null);
            return;
        }
    }

    /**
     * Получить сетевой адрес.
     * 
     * Возвращает связанный адрес, имя семейства адресов и порт сервера
     * в соответствии с сообщением операционной системы. Полезно для
     * определения, какой порт был назначен при получении адреса,
     * назначенного операционной системой.
     * 
     * Возвращает `null`, если сервер не запущен.
     * 
     * @return Сетевой адрес.
     */
    public function address():SocketAdress {
        if (srv == null)
            return null;

        return srv.address();
    }



    ///////////////////
    //   ЛИСТЕНЕРЫ   //
    ///////////////////

    private function onStart():Void {
        if (state == STATE_STARTING) { // <-- Нормальное выполнение
            state = STATE_ONLINE;
            emit(ServerEvent.ONLINE);
            return;
        }
        if (state == STATE_CLOSING) { // <-- Вызвали close() до фактического запуска, выключаем
            emit(ServerEvent.START_ERROR, new Error("Server start canceled"));
            srv.close(onClosed);
            return;
        }
    }

    private function onError(err:Error):Void {
        if (state == STATE_STARTING) { // <-- Если порт занят, мужет пульнуть
            state = STATE_CLOSED;
            emit(ServerEvent.START_ERROR, err);
            return;
        }
        if (state == STATE_ONLINE) { // <-- На тот случай, если могут быть другие срабатывания
            state = STATE_CLOSED;
            emit(ServerEvent.OFFLINE, err);
            return;
        }
    }

    private function onClosed(err:Error):Void {
        if (state == STATE_ONLINE) {
            state = STATE_OFFLINE;
            emit(ServerEvent.OFFLINE, err);
            return;
        }
        if (state == STATE_CLOSING) {
            state = STATE_CLOSED;
            return;
        }
    }

    private function onClientError(error:Error, socket:Socket):Void {
        socket.end("HTTP/1.1 400 Bad Request\r\n\r\n", "utf8");
    }

    private function onRequest(msg:IncomingMessage, res:ServerResponse):Void {

        // Получен новый запрос
        // Инициализируем объект запроса:
        var req     = new Request();
        req.server  = this;
        req.msg     = msg;
        req.res     = res;
        req.path    = Utils.readPath(msg.url);

        // API Не задано:
        if (route == null) {
            emit(ServerEvent.REQUEST, req);
            req.init(false);
            return;
        }

        // Метод не найден:
        req.api = route.api(msg.method, req.path);
        if (req.api == null) {
            emit(ServerEvent.REQUEST, req);
            req.init(false);
            return;
        }

        // Парсинг параметров URL:
        if (req.api.query)
            req.query = Utils.readQueryFromURL(msg.url);

        // Загрузка тела:
        emit(ServerEvent.REQUEST, req);
        req.init(!!req.api.body);
    }

    private function onRequestReady(req:Request):Void {

        // Запрос готов к дальнейшей обработке.
        // Делегируем выполнение:
        if (req.api != null) {
            req.api.callback(req);
            return;
        }

        // Раздаём статику, если это GET:
        if (req.msg.method == Method.Get) {
            sendStatic(req);
            return;
        }

        // Неизвестный запрос:
        send404(req);
    }



    /////////////////////////////////////////
    //   СТАНДАРТНЫЕ ОТВЕТЫ ПО УМОЛЧАНИЮ   //
    /////////////////////////////////////////

    /**
     * Функция отправки стандартного ответа: `400 Bad Request`. (По умолчанию)
     * 
     * Записывает в ответ код http статуса: `400`, отправляет
     * текстовое тело сообщения: `400 Bad Request` и
     * немедленно закрывает соединение.
     * 
     * Этот метод вызывается автоматически для всех входящих
     * соединений, если переданный ими тип данных не
     * соответствует ожидаемому типу, указанному в
     * `API.format`. Например, если метод принимает JSON,
     * а получен был текст, XML или т.п.
     * 
     * Подсказки:
     *   - Код `400` ответ означает, что сервер не понимает
     *     запрос из-за неверного синтаксиса. 
     *   - Вы можете назначить свой обработчик.
     * 
     * @param req Объект запроса.
     */
    public var send400:Request->Void = function(req) {
        req.res.statusCode = 400;
        req.res.setHeader(HeaderName.SERVER, req.server.name);
        req.res.setHeader(HeaderName.CACHE_CONTROL, CacheControl.NO_STORE);
        req.res.setHeader(HeaderName.CONTENT_TYPE, ContentType.TEXT);
        req.res.end("400 Bad Request");
    }

    /**
     * Функция отправки стандартного ответа: `404 Not Found`. (По умолчанию)
     * 
     * Записывает в ответ код http статуса: `404`, отправляет
     * текстовое тело сообщения: `404 Not Found` и немедленно
     * закрывает соединение.
     * 
     * Этот метод вызывается автоматически для всех входящих
     * соединений, если для них нет зарегистрированных методов
     * API или статических данных для GET запросов.
     * 
     * Подсказки:
     *   - Код `404` указывает, что сервер не может найти
     *     запрашиваемый ресурс.
     *   - Вы можете назначить свой обработчик.
     * 
     * @param req Объект запроса.
     */
    public var send404:Request->Void = function(req) {
        req.res.statusCode = 404;
        req.res.setHeader(HeaderName.SERVER, req.server.name);
        req.res.setHeader(HeaderName.CACHE_CONTROL, CacheControl.NO_STORE);
        req.res.setHeader(HeaderName.CONTENT_TYPE, ContentType.TEXT);
        req.res.end("404 Not Found");
    }

    /**
     * Функция отправки стандартного ответа: `413 Payload Too Large`. (По умолчанию)
     * 
     * Записывает в ответ код http статуса: `413`, отправляет
     * текстовое тело сообщения: `413 Payload Too Large` и
     * немедленно закрывает соединение.
     * 
     * Этот метод вызывается автоматически для всех входящих
     * соединений, если передаваемые ими данные превысили
     * лимит, заданный в: `API.bytesMax`.
     * 
     * Подсказки:
     *   - Код `413` указывает, что объект запроса больше, чем
     *     ограничения, определенные сервером.
     *   - Вы можете назначить свой обработчик.
     * 
     * @param req Объект запроса.
     */
    public var send413:Request->Void = function(req) {
        req.res.statusCode = 413;
        req.res.setHeader(HeaderName.SERVER, req.server.name);
        req.res.setHeader(HeaderName.CACHE_CONTROL, CacheControl.NO_STORE);
        req.res.setHeader(HeaderName.CONTENT_TYPE, ContentType.TEXT);
        req.res.end("413 Payload Too Large");
    }

    /**
     * Функция отправки стандартного ответа: `500 Internal Server Error`. (По умолчанию)
     * 
     * Записывает в ответ код http статуса: `500`, отправляет
     * текстовое тело сообщения: `500 Internal Server Error` и
     * немедленно закрывает соединение.
     * 
     * Этот метод вызывается автоматически для всех входящих
     * соединений, если во время их загрузки произошла ошибка.
     * 
     * Подсказки:
     *   - Код `500` указывает, что сервер столкнулся с ситуацией,
     *     которую он не знает как обработать. 
     *   - Вы можете назначить свой обработчик.
     * 
     * @param req Объект запроса.
     */
    public var send500:Request->Void = function(req) {
        req.res.statusCode = 500;
        req.res.setHeader(HeaderName.SERVER, req.server.name);
        req.res.setHeader(HeaderName.CACHE_CONTROL, CacheControl.NO_STORE);
        req.res.setHeader(HeaderName.CONTENT_TYPE, ContentType.TEXT);
        req.res.end("500 Internal Server Error");
    }

    /**
     * Функция отправки статических данных. (По умолчанию)
     * 
     * Для использования этого метода должно быть заполнено
     * свойство `content`. Если по указанному запросу статические
     * данные отсутствуют, отправляется стандартный 404 ответ.
     * 
     * Этот метод вызывается автоматически для всех входящих
     * GET запросов, если для них не зарегистрирован метод API.
     * Вызов метода закрывает соединение.
     * 
     * *п.с. Вы можете назначить свой обработчик.*
     * 
     * @param req Объект запроса.
     */
    public var sendStatic:Request->Void = function(req) {

        // Отправка статического контента.
        // Статические данные не заданы:
        if (req.server.content == null) {
            req.server.send404(req);
            return;
        }

        // Поиск файла:
        var name = req.path.join(Path.sep);
        var file = req.server.content.get(name);
        if (file == null) {
            file = req.server.content.get(name + req.server.indexFile);
            if (file == null) {
                file = req.server.content.get(name + Path.sep + req.server.indexFile);
                if (file == null) {
                    req.server.send404(req);
                    return;
                }
            }
        }

        // Файл найден
        // Поддержка if-none-match:
        var v = req.msg.headers["if-none-match"];
        if (v != null && v == '"' + file.hash + '"') {
            req.res.statusCode = 304;
            req.res.setHeader(HeaderName.SERVER, req.server.name);
            req.res.setHeader(HeaderName.CACHE_CONTROL, req.server.cacheControl);
            req.res.setHeader(HeaderName.ETAG, '"' + file.hash + '"');
            req.res.end();
            return;
        }

        // Отправка:
        req.res.statusCode = 200;
        req.res.setHeader(HeaderName.SERVER, req.server.name);
        req.res.setHeader(HeaderName.CACHE_CONTROL, req.server.cacheControl);
        req.res.setHeader(HeaderName.ETAG, '"' + file.hash + '"');
        req.res.setHeader(HeaderName.CONTENT_LENGTH, Std.string(file.data.length));

        if (file.mime == null)
            req.res.setHeader(HeaderName.CONTENT_TYPE, ContentType.UNKNOWN);
        else
            req.res.setHeader(HeaderName.CONTENT_TYPE, file.mime.contentType);

        if (file.isCompressed)
            req.res.setHeader(HeaderName.CONTENT_ENCODING, Cache.COMPRESS_TYPE);

        req.res.end(file.data);
    }
}

/**
 * Параметры для запуска сервера HTTP REST API.
 */
typedef ServerHttpParams =
{
    /**
     * Порт прослушки.
     */
    var port:Int;

    /**
     * Хост прослушки.
     */
    var host:String;

    /**
     * Количество миллисекунд бездействия до истечения времени ожидания сокета. (mc)
     * 
     * Значение `0` отключит время ожидания для входящих соединений.
     * 
     * По умолчанию: `10000` (10 секунд)
     */
    @:optional var timeout:Int;

    /**
     * Ограничивает максимальное количество заголовков ответа.
     * 
     * Если установлено значение `0`, ограничение не будет применяться.
     * 
     * По умолчанию: `50`
     */
    @:optional var maxHeadersCount:Int;
}

/**
 * Параметры для запуска сервера HTTPS REST API.
 */
typedef ServerHttpsParams = 
{
    >ServerHttpParams,

    /**
     * Параметры для запуска SSL сервера.
     */
    var ssl:HttpsCreateServerOptions;
}