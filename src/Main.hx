package;

import js.lib.Error;
import rest.server.Request;
import rest.server.Server;
import rest.server.BodyFormat;
import rest.server.ServerEvent;
import rest.route.Route;
import rest.cache.Cache;
import rest.cache.CacheEvent;
import rest.cache.CacheFile;

/**
 * Пример работы сервера.
 */
class Main 
{
    static private var cache:Cache;
    static private var route:Route;
    static private var server:Server;

    /**
     * Точка входа.
     */
    static function main() {
        
        // Кеш файлов для раздачи статики:
        cache = new Cache();
        cache.on(CacheEvent.FILE_ADD,       onCacheFileAdd);
        cache.on(CacheEvent.FILE_REMOVE,    onCacheFileRemove);
        cache.on(CacheEvent.FILE_UPDATE,    onCacheFileUpdate);
        cache.on(CacheEvent.FILE_COMPRESS,  onCacheFileCompress);
        cache.on(CacheEvent.UPDATE_START,   onCacheUpdateStart);
        cache.on(CacheEvent.UPDATE_END,     onCacheUpdateEnd);
        cache.on(CacheEvent.ERROR,          onCacheError);
        cache.root = "www"; // <-- Корень статики

        // Карта API:
        route = new Route();
        route.get("/rnd", getRandom);
        route.post("user", setUser, true, true, BodyFormat.JSON);

        // Сервер:
        server = new Server();
        server.route = route;
        server.content = cache;
        server.on(ServerEvent.SERVER_START, onServerStart);
        server.on(ServerEvent.SERVER_DOWN, onServerDown);
        server.on(ServerEvent.SERVER_ERROR, onServerError);
        server.on(ServerEvent.SERVER_REQUEST, onServerRequest);
        server.startHttp({ host:"127.0.0.1", port:8080 });
    }

    // Обработчики:
    static private function getRandom(req:Request):Void {
        req.res.end(Math.random() + '!');
    }

    static private function setUser(req:Request):Void {
        req.res.end('Вася я, ну');
    }

    // Сервер:
    static private function onServerStart():Void {
        trace("Сервер запущен: " + server.address().address + ':' + server.address().port);
    }

    static private function onServerDown():Void {
        trace("Сервер остановлен");
    }

    static private function onServerError(err:Error):Void {
        trace("Ошибка сервера");
        trace(err);
    }

    static private function onServerRequest(req:Request):Void {
        trace("Новый запрос:", req.msg.url);
    }

    // Кеш:
    static private function onCacheUpdateStart():Void {
        trace("Обновление файлов кеша началось");
    }
    static private function onCacheUpdateEnd(bytes:Int):Void {
        trace("Обновление файлов кеша завершено, размер: " + bytes + " байт");
    }
    static private function onCacheFileAdd(file:CacheFile):Void {
        trace("Добавлен новый файл в кеш: " + file.path);
    }
    static private function onCacheFileUpdate(file:CacheFile):Void {
        trace("Обновлён файл в кеше: " + file.path);
    }
    static private function onCacheFileRemove(file:CacheFile):Void {
        trace("Удалён файл из кеша: " + file.path);
    }
    static private function onCacheFileCompress(file:CacheFile):Void {
        trace("Сжат файл в кеше: " + file.path);
    }
    static private function onCacheError(error:Error):Void {
        trace("Ошибка кеша");
        trace(error);
    }
}