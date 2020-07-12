package rest.mime;

import haxe.DynamicAccess;

/**
 * Список со всеми известными типами данных.
 * 
 * Содержит таблицу наиболее часто используемых
 * типов данных. Может дополняться по мере развития
 * библиотеки или прямо в рантайме.
 * 
 * Статический класс.
 */
class MimeTypeList
{
    /**
     * Получить описание типа данных.
     * 
     * Возвращает объект с описанием типа данных или `undefined`,
     * если для указанного расширения нет информации о типе.
     * 
     * @param ext Расширение типа данных. (Например: `.jpg`)
     * @return Описание типа данных.
     */
    inline static public function get(ext:String):MimeType {
        return types[ext];
    }

    /**
     * Список со всеми известными типами данных.
     * 
     * Не может быть `null`.
     */
    static public var types:DynamicAccess<MimeType> = 
    {    
        // TEXT
        ".txt":             { ext:".txt",       isCompressed:false,   contentType:"text/plain; charset=utf-8",          title:"Text, (generally ASCII or ISO 8859-n)" },
        ".css":             { ext:".css",       isCompressed:false,   contentType:"text/css; charset=utf-8",            title:"Cascading Style Sheets (CSS)" },
        ".csv":             { ext:".csv",       isCompressed:false,   contentType:"text/csv; charset=utf-8",            title:"Comma-separated values (CSV)" },
        ".htm":             { ext:".htm",       isCompressed:false,   contentType:"text/html; charset=utf-8",           title:"HyperText Markup Language (HTML)" },
        ".html":            { ext:".html",      isCompressed:false,   contentType:"text/html; charset=utf-8",           title:"HyperText Markup Language (HTML)" },
        ".js":              { ext:".js",        isCompressed:false,   contentType:"text/javascript; charset=utf-8",     title:"JavaScript" },
        ".mjs":             { ext:".mjs",       isCompressed:false,   contentType:"text/javascript; charset=utf-8",     title:"JavaScript module" },
        ".xml":             { ext:".xml",       isCompressed:false,   contentType:"text/xml; charset=utf-8",            title:"XML" },
        ".md":              { ext:".md",        isCompressed:false,   contentType:"text/markdown; charset=utf-8",       title:"Markdown" },
        ".markdown":        { ext:".markdown",  isCompressed:false,   contentType:"text/markdown; charset=utf-8",       title:"Markdown" },
        ".ics":             { ext:".ics",       isCompressed:false,   contentType:"text/calendar; charset=utf-8",       title:"iCalendar format" },
        
        // IMAGE
        ".jpg":             { ext:".jpg",       isCompressed:true,    contentType:"image/jpeg",                 title:"JPEG image" },
        ".jpeg":            { ext:".jpeg",      isCompressed:true,    contentType:"image/jpeg",                 title:"JPEG image" },
        ".jfif":            { ext:".jfif",      isCompressed:true,    contentType:"image/jpeg",                 title:"JPEG image" },
        ".pjpeg":           { ext:".pjpeg",     isCompressed:true,    contentType:"image/jpeg",                 title:"JPEG image" },
        ".pjp":             { ext:".pjp",       isCompressed:true,    contentType:"image/jpeg",                 title:"JPEG image" },
        ".png":             { ext:".png",       isCompressed:true,    contentType:"image/png",                  title:"Portable Network Graphics" },
        ".gif":             { ext:".gif",       isCompressed:true,    contentType:"image/gif",                  title:"Graphics Interchange Format (GIF)" },
        ".ico":             { ext:".ico",       isCompressed:false,   contentType:"image/x-icon",               title:"Icon format" },
        ".cur":             { ext:".cur",       isCompressed:false,   contentType:"image/x-icon",               title:"Icon format, cursor" },
        ".apng":            { ext:".apng",      isCompressed:false,   contentType:"image/apng",                 title:"Animated Portable Network Graphics" },
        ".bmp":             { ext:".bmp",       isCompressed:false,   contentType:"image/bmp",                  title:"Windows OS/2 Bitmap Graphics" },
        ".svg":             { ext:".svg",       isCompressed:false,   contentType:"image/svg+xml",              title:"Scalable Vector Graphics (SVG)" },
        ".tif":             { ext:".tif",       isCompressed:false,   contentType:"image/tiff",                 title:"Tagged Image File Format (TIFF)" },
        ".tiff":            { ext:".tiff",      isCompressed:false,   contentType:"image/tiff",                 title:"Tagged Image File Format (TIFF)" },
        ".webp":            { ext:".webp",      isCompressed:false,   contentType:"image/webp",                 title:"WEBP image" },
        
        // FONTS
        ".ttf":             { ext:".ttf",       isCompressed:false,   contentType:"font/ttf",                   title:"TrueType Font" },
        ".otf":             { ext:".otf",       isCompressed:false,   contentType:"font/otf",                   title:"OpenType font" },
        ".woff":            { ext:".woff",      isCompressed:false,   contentType:"font/woff",                  title:"Web Open Font Format (WOFF)" },
        ".woff2":           { ext:".woff2",     isCompressed:false,   contentType:"font/woff2",                 title:"Web Open Font Format (WOFF)" },
        
        // AUDIO
        ".aac":             { ext:".aac",       isCompressed:true,    contentType:"audio/aac",                  title:"AAC audio" },
        ".mid":             { ext:".mid",       isCompressed:false,   contentType:"audio/midi audio/x-midi",    title:"Musical Instrument Digital Interface (MIDI)" },
        ".midi":            { ext:".midi",      isCompressed:false,   contentType:"audio/midi audio/x-midi",    title:"Musical Instrument Digital Interface (MIDI)" },
        ".mp3":             { ext:".mp3",       isCompressed:true,    contentType:"audio/mpeg",                 title:"MP3 audio" },
        ".mp4":             { ext:".mp4",       isCompressed:true,    contentType:"application/mp4",            title:"MPEG-4 Part 14 (MP4)" },
        ".oga":             { ext:".oga",       isCompressed:true,    contentType:"audio/ogg",                  title:"OGG audio" },
        ".opus":            { ext:".opus",      isCompressed:true,    contentType:"audio/opus",                 title:"Opus audio" },
        ".wav":             { ext:".wav",       isCompressed:false,   contentType:"audio/wav",                  title:"Waveform Audio Format" },
        ".weba":            { ext:".weba",      isCompressed:true,    contentType:"audio/webm",                 title:"WEBM audio" },
        
        // VIDEO
        ".avi":             { ext:".avi",       isCompressed:true,    contentType:"video/x-msvideo",            title:"Audio Video Interleave" },
        ".mpeg":            { ext:".mpeg",      isCompressed:true,    contentType:"video/mpeg",                 title:"MPEG Video" },
        ".ogv":             { ext:".ogv",       isCompressed:true,    contentType:"video/ogg",                  title:"OGG video" },
        ".ts":              { ext:".ts",        isCompressed:true,    contentType:"video/mp2t",                 title:"MPEG transport stream" },
        ".webm":            { ext:".webm",      isCompressed:true,    contentType:"video/webm",                 title:"WEBM video" },
        
        // APPLICATION
        ".json":            { ext:".json",      isCompressed:false,   contentType:"application/json",                                                           title:"JSON format" },
        ".jsonld":          { ext:".jsonld",    isCompressed:false,   contentType:"application/ld+json",                                                        title:"JSON-LD format" },
        ".xhtml":           { ext:".xhtml",     isCompressed:false,   contentType:"application/xhtml+xml",                                                      title:"XHTML" },
        ".csh":             { ext:".csh",       isCompressed:false,   contentType:"application/x-csh",                                                          title:"C-Shell script" },
        ".php":             { ext:".php",       isCompressed:false,   contentType:"application/php",                                                            title:"Hypertext Preprocessor (Personal Home Page)" },
        ".sh":              { ext:".sh",        isCompressed:false,   contentType:"application/x-sh",                                                           title:"Bourne shell script" },
        ".rtf":             { ext:".rtf",       isCompressed:false,   contentType:"application/rtf",                                                            title:"Rich Text Format (RTF)" },
        ".xul":             { ext:".xul",       isCompressed:false,   contentType:"application/vnd.mozilla.xul+xml",                                            title:"XUL" },
        ".eot":             { ext:".eot",       isCompressed:false,   contentType:"application/vnd.ms-fontobject",                                              title:"MS Embedded OpenType fonts" },
        ".rar":             { ext:".rar",       isCompressed:true,    contentType:"application/vnd.rar",                                                        title:"RAR archive" },
        ".zip":             { ext:".zip",       isCompressed:true,    contentType:"application/zip",                                                            title:"ZIP archive" },
        ".7z":              { ext:".7z",        isCompressed:true,    contentType:"application/x-7z-compressed",                                                title:"7-zip archive" },
        ".arc":             { ext:".arc",       isCompressed:true,    contentType:"application/x-freearc",                                                      title:"Archive document (multiple files embedded)" },
        ".bz":              { ext:".bz",        isCompressed:true,    contentType:"application/x-bzip",                                                         title:"BZip archive" },
        ".bz2":             { ext:".bz2",       isCompressed:true,    contentType:"application/x-bzip2",                                                        title:"BZip2 archive" },
        ".tar":             { ext:".tar",       isCompressed:true,    contentType:"application/x-tar",                                                          title:"Tape Archive (TAR)" },
        ".jar":             { ext:".jar",       isCompressed:true,    contentType:"application/java-archive",                                                   title:"Java Archive (JAR)" },
        ".mpkg":            { ext:".mpkg",      isCompressed:false,   contentType:"application/vnd.apple.installer+xml",                                        title:"Apple Installer Package" },
        ".ogx":             { ext:".ogx",       isCompressed:false,   contentType:"application/ogg",                                                            title:"OGG" },
        ".swf":             { ext:".swf",       isCompressed:true,    contentType:"application/x-shockwave-flash",                                              title:"Small web format (SWF) or Adobe Flash document" },
        ".torrent":         { ext:".torrent",   isCompressed:false,   contentType:"application/x-bittorrent",                                                   title:"BitTorrent" },
        ".pdf":             { ext:".pdf",       isCompressed:false,   contentType:"application/pdf",                                                            title:"Adobe Portable Document Format (PDF)" },
        ".abw":             { ext:".abw",       isCompressed:false,   contentType:"application/x-abiword",                                                      title:"AbiWord document" },
        ".azw":             { ext:".azw",       isCompressed:false,   contentType:"application/vnd.amazon.ebook",                                               title:"Amazon Kindle eBook format" },
        ".bin":             { ext:".bin",       isCompressed:false,   contentType:"application/octet-stream",                                                   title:"Any kind of binary data" },
        ".doc":             { ext:".doc",       isCompressed:false,   contentType:"application/msword",                                                         title:"Microsoft Word" },
        ".epub":            { ext:".epub",      isCompressed:false,   contentType:"application/epub+zip",                                                       title:"Electronic publication (EPUB)" },
        ".gz":              { ext:".gz",        isCompressed:true,    contentType:"application/gzip",                                                           title:"GZip Compressed Archive" },
        ".vsd":             { ext:".vsd",       isCompressed:false,   contentType:"application/vnd.visio",                                                      title:"Microsoft Visio" },
        ".ppt":             { ext:".ppt",       isCompressed:false,   contentType:"application/vnd.ms-powerpoint",                                              title:"Microsoft PowerPoint" },
        ".xls":             { ext:".xls",       isCompressed:false,   contentType:"application/vnd.ms-excel",                                                   title:"Microsoft Excel" },
        ".odt":             { ext:".odt",       isCompressed:false,   contentType:"application/vnd.oasis.opendocument.text",                                    title:"OpenDocument text document" },
        ".odp":             { ext:".odp",       isCompressed:false,   contentType:"application/vnd.oasis.opendocument.presentation",                            title:"OpenDocument presentation document" },
        ".ods":             { ext:".ods",       isCompressed:false,   contentType:"application/vnd.oasis.opendocument.spreadsheet",                             title:"OpenDocument presentation document" },
        ".docx":            { ext:".docx",      isCompressed:false,   contentType:"application/vnd.openxmlformats-officedocument.wordprocessingml.document",    title:"Microsoft Word (OpenXML)" },
        ".pptx":            { ext:".pptx",      isCompressed:false,   contentType:"application/vnd.openxmlformats-officedocument.presentationml.presentation",  title:"Microsoft PowerPoint (OpenXML)" }
    };
}