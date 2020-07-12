package rest.headers;

/**
 * Значения для заголовка: `Content-Type`.
 * 
 * Перечисление содержит некоторые, часто используемые
 * значения для этого типа заголовка. Их полный список
 * огромен.
 * 
 * Может дополняться по мере необходимости.
 * 
 * @see Документация: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
 */
@:enum abstract ContentType(String) to String
{
    /**
     * Неизвестный тип данных. (По умолчанию)
     * 
     * Этот тип должен использоваться всегда, когда
     * не известен реальный формат файла.
     */
    var UNKNOWN = "application/octet-stream";

    /**
     * Текст в формате JSON. (UTF-8)
     * 
     * Кодировка по умолчанию: `UTF-8`, нет необходимости
     * указывать повторно.
     * 
     * Если текст представлен в другой кодировке, он
     * должен быть указан вторым атрибутом:
     * `application/json; charset=utf-32`.
     */
    var JSON = "application/json";

    /**
     * Обычный текст. (UTF-8)
     */
    var TEXT = "text/plain; charset=utf-8";

    /**
     * Текст в формате HTML. (UTF-8)
     */
    var HTML = "text/html; charset=utf-8";
}