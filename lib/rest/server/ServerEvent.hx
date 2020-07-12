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
     * Сервер запущен.
     * 
     * Диспетчерезируется после запуска прослушки
     * входящих соединений web сервером.
     */
    var SERVER_START:ServerEvent<Void->Void> = "serverStart";

    /**
     * Сервер завершил свою работу.
     * 
     * Может диспетчерезироваться в случае непредвиденной
     * остановки web сервера.
     */
    var SERVER_DOWN:ServerEvent<Void->Void> = "serverDown";

    /**
     * Ошибка сервера.
     * 
     * Диспетчерезируется в случае ошибки запуска или во
     * время работы web сервера.
     * 
     * Событие содержит описание ошибки.
     */
    var SERVER_ERROR:ServerEvent<Error->Void> = "serverError";

    /**
     * Получен новый запрос.
     * 
     * Диспетчерезируется при получении нового запроса и до
     * отправки его какому либо обработчику. Тело запроса ещё
     * не загружено. (Если включена загрузка тела)
     * 
     * Может быть полезно для логирования.
     * 
     * Событие содержит объект запроса.
     */
    var SERVER_REQUEST:ServerEvent<Request->Void> = "serverRequest";
}