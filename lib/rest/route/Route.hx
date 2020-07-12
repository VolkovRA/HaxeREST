package rest.route;

import rest.server.BodyFormat;
import rest.server.Request;
import js.node.http.Method;
import haxe.DynamicAccess;

/**
 * Карта методов API.
 * 
 * Класс выполняет задачу определения вызываемого метода API
 * на основе принятого URL запроса.
 * 
 * Пример оформления API:
 * ```
 * "/user"; // Для запросов вида: /user, /user/23, /user/23,24,25, /user/progress и т.д.
 * "/user/score"; // Для запросов вида: /user/score, /user/score/top и т.д.
 * ```
 * 
 * Применение:
 *   1. Создать экземпляр класса.
 *   2. Заполнить карту, используя методы: `add()`, `get()`, `post()` и т.д.
 *   3. Вызвать метод `api()` для получения зарегистрированного метода API.
 * 
 * При поиске вызываемого метода маршрутизатор ищет самый глубокий
 * для данного URL. Таким образом, вы можете задать разные обработчики
 * для запросов: `users/` и `users/score/`. Если метод не найден,
 * возвращается `null`.
 * 
 * Глубина вложенности определяется слешами в URL адресе: `/`.
 */
class Route
{
    private var map = new DynamicAccess<PathNode>();
    
    /**
     * Создать карту API.
     */
    public function new() {
    }

    /**
     * Добавить метод REST API.
     * 
     * Регистрирует переданный метод в общей карте маршрутизации.
     * Вызов игнорируется, если передаётся `null`.
     * 
     * @param api REST API Метод для входящих запросов.
     */
    public function add(api:API):Void {
        if (api == null)
            return;
        
        // Корневой узел:
        var node = map[api.method];
        if (node == null) {
            node = {
                api:null,
                childs:null,
            };
            map[api.method] = node;
        }

        // Получаем узел: (Создаём новые, если их нет)
        var path = Utils.readPath(api.url);
        var len = path.length;
        var i = 0;
        while (i < len) {
            var key = path[i++];
            if (node.childs == null) {
                var node2:PathNode = {
                    api:null,
                    childs:null,
                }
                node.childs = {};
                node.childs[key] = node2; 
                node = node2;
            }
            else {
                var node2 = node.childs[key];
                if (node2 == null) {
                    node2 = {
                        api:null,
                        childs:null,
                    }
                    node.childs[key] = node2;
                }
                node = node2;
            }
        }

        // Записываем колбек:
        node.api = api;
    }

    /**
     * Получить метод API для указанного вызова.
     * 
     * Метод возвращает зарегистрированный ранее метод REST API
     * для указанного вызова или `null`, если такого метода нет. 
     * 
     * @param method Метов вызова.
     * @param path Путь вызова.
     * @return API Метод.
     */
    public function api(method:Method, path:Path):API {
        var node = map[method];
        if (node == null)
            return null;

        var i = 0;
        var len = path.length;
        while (i < len) {
            if (node.childs == null)
                return node.api;

            var node2 = node.childs[path[i++]];
            if (node2 == null)
                return node.api;

            node = node2;
        }

        return node.api;
    }



    ///////////////////
    //   САХАРОЧЕК   //
    ///////////////////

    /**
     * Добавить GET метод REST API.
     * @param url URL для вызова метода. (Относительно корня сайта)
     * @param callback Обработчик вызова.
     * @param query Распарсить параметры, переданные в URL запроса.
     * @param body Загрузить тело запроса, переданное клиентом.
     * @param format Формат данных получаемых от клиента в теле запроса.
     */
    public function get(url:String, callback:Request->Void, query:Bool = true, body:Bool = false, format:BodyFormat = BodyFormat.TEXT):Void {
        add({ method:Method.Get, url:url, callback:callback, query:query, body:body, bodyFormat:format });
    }

    /**
     * Добавить POST метод REST API.
     * @param url URL для вызова метода. (Относительно корня сайта)
     * @param callback Обработчик вызова.
     * @param query Распарсить параметры, переданные в URL запроса.
     * @param body Загрузить тело запроса, переданное клиентом.
     * @param format Формат данных получаемых от клиента в теле запроса.
     */
    public function post(url:String, callback:Request->Void, query:Bool = true, body:Bool = false, format:BodyFormat = BodyFormat.TEXT):Void {
        add({ method:Method.Post, url:url, callback:callback, query:query, body:body, bodyFormat:format  });
    }

    /**
     * Добавить PUT метод REST API.
     * @param url URL для вызова метода. (Относительно корня сайта)
     * @param callback Обработчик вызова.
     * @param query Распарсить параметры, переданные в URL запроса.
     * @param body Загрузить тело запроса, переданное клиентом.
     * @param format Формат данных получаемых от клиента в теле запроса.
     */
    public function put(url:String, callback:Request->Void, query:Bool = true, body:Bool = false, format:BodyFormat = BodyFormat.TEXT):Void {
        add({ method:Method.Put, url:url, callback:callback, query:query, body:body, bodyFormat:format  });
    }

    /**
     * Добавить DELETE метод REST API.
     * @param url URL для вызова метода. (Относительно корня сайта)
     * @param callback Обработчик вызова.
     * @param query Распарсить параметры, переданные в URL запроса.
     * @param body Загрузить тело запроса, переданное клиентом.
     * @param format Формат данных получаемых от клиента в теле запроса.
     */
    public function delete(url:String, callback:Request->Void, query:Bool = true, body:Bool = false, format:BodyFormat = BodyFormat.TEXT):Void {
        add({ method:Method.Delete, url:url, callback:callback, query:query, body:body, bodyFormat:format  });
    }

    /**
     * Добавить OPTIONS метод REST API.
     * @param url URL для вызова метода. (Относительно корня сайта)
     * @param callback Обработчик вызова.
     * @param query Распарсить параметры, переданные в URL запроса.
     * @param body Загрузить тело запроса, переданное клиентом.
     * @param format Формат данных получаемых от клиента в теле запроса.
     */
    public function options(url:String, callback:Request->Void, query:Bool = true, body:Bool = false, format:BodyFormat = BodyFormat.TEXT):Void {
        add({ method:Method.Options, url:url, callback:callback, query:query, body:body, bodyFormat:format  });
    }
}

/**
 * Узел дерева API.
 */
private typedef PathNode =
{
    /**
     * Зарегистрированый метод API.
     * 
     * Может быть `null`
     */
    var api:API;

    /**
     * Потомки.
     * 
     * Может быть `null`
     */
    var childs:DynamicAccess<PathNode>;
}