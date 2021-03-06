package rest.headers;

/**
 * Значения для заголовка: `Cache-Control`.
 * 
 * Заголовок используется для задания инструкций кэширования как для
 * запросов, так и для ответов. Инструкции кэширования однонаправленные:
 * заданная инструкция в запросе не подразумевает, что такая же
 * инструкция будет указана в ответе.
 * 
 * Инструкции не чувствительны к регистру и имеют необязательный аргумент,
 * который может быть указан как в кавычках, так и без них. Несколько
 * инструкций разделяются запятыми.
 * 
 * Перечисление содержит некоторые, часто используемые значения заголовка.
 * 
 * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/headers/Cache-Control
 */
@:enum abstract CacheControl(String) to String
{
    /**
     * Задает максимальное время (sec) в течение которого ресурс будет считаться
     * актуальным. В отличие от Expires, данная инструкция является
     * относительной по отношению ко времени запроса.
     */
    var MAX_AGE = "max-age=";

    /**
     * Указывает, что ответ может быть закэширован в любом кэше.
     */
    var PUBLIC = "public";

    /**
     * Указывает, что ответ предназначен для одного пользователя и не должен
     * помещаться в разделяемый кэш. Частный кэш может хранить ресурс.
     */
    var PRIVATE = "private";

    /**
     * Указывает на необходимость отправить запрос на сервер для валидации ресурса
     * перед использованием закешированных данных.
     */
    var NO_CACHE = "no-cache";

    /**
     * Указывает на необходимость отправить запрос на сервер для валидации ресурса
     * перед использованием закешированных данных.
     */
    var ONLY_IF_CACHED = "only-if-cached";

    /**
     * Кэш не должен хранить никакую информацию о запросе и ответе.
     */
    var NO_STORE = "no-store";
}