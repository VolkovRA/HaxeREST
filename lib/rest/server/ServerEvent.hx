package rest.server;

import haxe.Constraints.Function;
import js.lib.Error;
import js.node.events.EventEmitter.Event;

/**
 * Событие сервера REST API.
 */
@:enum abstract ServerEvent<T:Function>(Event<T>) to Event<T>
{
    /**
     * Получен новый запрос.
     * 
     * Это событие диспетчерезируется для каждого входящего
     * запроса сразу после разбора его URL и до передачи
     * любому обработчику API.
     * 
     * Может быть полезно для логирования. Событие содержит
     * ссылку на входящий запрос.
     */
    var REQUEST:ServerEvent<Request->Void> = "serverRequest";

    /**
     * Сервер API запущен.
     * 
     * Событие диспетчерезируется после успешного запуска
     * сервера REST API. Готов к обработке запросов.
     */
    var ONLINE:ServerEvent<Void->Void> = "serverOnline";

    /**
     * Сервер API отключен.
     * 
     * Событие диспетчерезируется при отключении сервера по
     * любой причине. Событие несёт объект ошибки, если это
     * произошло в результате какого либо сбоя.
     */
    var OFFLINE:ServerEvent<Null<Error>->Void> = "serverOffline";

    /**
     * Ошибка запуска сервера API.
     * 
     * Это событие диспетчерезируется в случае ошибки запуска
     * сервера REST API. Смотрите методы: `start()`.
     * 
     * Событие содержит возникшую ошибку. (Приложение не падает)
     */
    var START_ERROR:ServerEvent<Error->Void> = "serverStartError";
}