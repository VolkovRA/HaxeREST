# HAXE Фреймворк для создания REST API на NodeJS

Описание
------------------------------

Это небольшой Haxe фреймворк для создания REST API на NodeJS.
Не имеет других зависимостей, кроме определений для NodeJS.

Особенности:
  1. Имеет встроенный маршрутизатор для удобного создания API.
  2. Имеет гибкие настройки для каждого отдельного метода API:
      - Включение/выключение принимаемых данных.
      - Встроенный парсер для стандартных форматов данных в принимаемом теле запроса: String, JSON, URI, Buffer, Query.
      - Встроенный парсер для поисковых параметров в строке запроса URL.
      - Лимит на максимальный объём принимаемых данных.
      - Доступ к нативным объектам NodeJS для обработки запроса.
  3. Имеет готовые обработчики для стандартных ошибок: 400, 404, 500 ...
  4. Позволяет переопределить любой из стандартных обработчиков ошибок.
  5. Поддерживает https.
  6. Может раздавать статику.

Как сервер для раздачи статики:
  1. Раздачу статики можно не включать.
  2. Сжимает и кеширует всю статику в ОЗУ для максимально быстрого ответа.
  3. Следит за изменениями в публичной директории и оперативно подгружает изменённые файлы для раздачи актуальной версии.
  4. Сжимает статику при помощи gzip.
  5. Использует умное браузерное кеширование на основе etag.
  6. Имеет таблицу стандартных mime типов и умеет отправлять корректные заголовки для большинства расппространённых форматов файлов.

**Важно:** Не предназначен для раздачи объёмных данных, так как вся статика загружается в ОЗУ!

Пример использования
------------------------------
```
// Кеш файлов для раздачи статики:
cache = new Cache();
cache.root = "www";

// Карта API:
route = new Route();
route.get("/rnd", getRandom);
route.post("user", setUser, true, true, BodyFormat.JSON);

// Сервер:
server = new Server();
server.route = route;
server.content = cache;
server.startHttp({ host:"127.0.0.1", port:8080 });
```

Подключение в Haxe
------------------------------

1. Установите haxelib, чтобы можно было использовать библиотеки Haxe.
2. Выполните в терминале команду, чтобы установить библиотеку rest глобально себе на локальную машину:
```
haxelib git rest https://github.com/VolkovRA/HaxeREST master
```
Синтаксис команды:
```
haxelib git [project-name] [git-clone-path] [branch]
haxelib git minject https://github.com/massiveinteractive/minject.git         # Use HTTP git path.
haxelib git minject git@github.com:massiveinteractive/minject.git             # Use SSH git path.
haxelib git minject git@github.com:massiveinteractive/minject.git v2          # Checkout branch or tag `v2`.
```
3. Добавьте в свой проект библиотеку rest, чтобы использовать её в коде. Если вы используете HaxeDevelop, то просто добавьте в файл .hxproj запись:
```
<haxelib>
	<library name="rest" />
</haxelib>
```

Смотрите дополнительную информацию:
 * [Документация Haxelib](https://lib.haxe.org/documentation/using-haxelib/ "Using Haxelib")
 * [Документация HaxeDevelop](https://haxedevelop.org/configure-haxe.html "Configure Haxe")