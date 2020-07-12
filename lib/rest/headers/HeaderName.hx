package rest.headers;

/**
 * Имя заголовка HTTP/S.
 * 
 * Перечисление содержит часто используемые заголовки
 * в http/s запросах для удобства их применения.
 * 
 * Может дополняться по мере необходимости.
 */
@:enum abstract HeaderName(String) to String
{
    /**
     * Информация о сервере и его ПО.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Server
     */
    var SERVER = "Server";
    
    /**
     * Тип содержимого в запросе.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
     */
    var CONTENT_TYPE = "Content-Type";
    
    /**
     * Открывает доступ к ресурсу для веб страниц, расположенных на разных доменах.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Access-Control-Allow-Origin
     */
    var ACCESS_CONTROL_ALLOW_ORIGIN = "Access-Control-Allow-Origin";
    
    /**
     * Заголовок используется в OPTIONS запросах, когда страница запрашивает,
     * какие заголовки она может слать в реальном запросе.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers
     */
    var ACCESS_CONTROL_ALLOW_HEADERS = "Access-Control-Allow-Headers";
    
    /**
     * Используется для управления кешированием.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/headers/Cache-Control
     */
    var CACHE_CONTROL = "Cache-Control";
    
    /**
     * Отпечаток пальца. (Хеш) Используется для кеширования.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
     */
    var ETAG = "ETag";
    
    /**
     * Размер тела сообщения в байтах.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Length
     */
    var CONTENT_LENGTH = "Content-Length";
    
    /**
     * Тип сжатия сообщения.
     * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding
     */
    var CONTENT_ENCODING = "Content-Encoding";
}