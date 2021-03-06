package rest.server;

/**
 * Формат данных принимаемого тела сообщения.
 * 
 * Перечисление используется для указания типа передаваемых
 * данных в теле сообщения. (Не путайте с данными в строке
 * URL запроса) Это полезно при использовании POST запросов,
 * для указания способа начальной интерпретации данных перед
 * их передачей в обработчик REST API.
 * 
 * Запрос завершается ошибкой, если серверу не удаётся
 * интерпретировать полученные от клиента данные к заявленному
 * типу. В этом случае запрос завершается ошибкой: `Server.send400()`
 * и объект не передаётся в обработчик API.
 * 
 * Передаваемые, текстовые данные должны быть в кодировке UTF-8.
 */
@:enum abstract BodyFormat(String) to String
{
    /**
     * Текстовые данные. 
     * - Пример ожидаемых данных: `Меня зовут Вася`
     * - Тип полученных данных: `String`
     */
    var TEXT = "text";

    /**
     * Необработанные, двоичные данные. 
     * - Пример передаваемых данных: Картинки, музыка, что угодно.
     * - Тип полученных данных: `Buffer` 
     */
    var BINARY = "binary";

    /**
     * JS Объект, полученный в результате разбора JSON строки. 
     * - Пример ожидаемых данных: `{ name:"Вася", age:15, sex:"man" }`.
     * - Тип полученных данных: `DynamicAccess<String>`
     */
    var JSON = "json";

    /**
     * JS Объект, полученный в результате разбора URI строки.
     * - Пример ожидаемых данных: `name=Вася&age=15&sex=man`.
     * - Тип полученных данных: `DynamicAccess<String>`
     */
    var QUERY = "query";
}