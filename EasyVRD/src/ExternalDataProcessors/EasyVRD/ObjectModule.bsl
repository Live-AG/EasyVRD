
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Репозиторий обработки https://github.com/Live-AG/EasyVRD
//////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	
#Область ПрограммныйИнтерфейс

// Функция формирует XML-документ на основе переданных данных заполнения
//
// Параметры:
//  ДанныеЗаполнения - Структура - Данные для заполнения XML-документа
//
// Возвращаемое значение:
//   Строка - Сформированный XML-документ в виде строки
//
Функция СформироватьДанныеXML(ДанныеЗаполнения) Экспорт
	
	ПараметрыЗаписиXML = Новый ПараметрыЗаписиXML("UTF-8",	// Кодировка
												"1.0",				// Версия
												Истина,			// Отступ
												Истина,			// ОтступАтрибутов
												Символы.Таб);		// СимволыОтступа
												
	ЗаписьXML = Новый ЗаписьXML();
	ЗаписьXML.УстановитьСтроку(ПараметрыЗаписиXML);
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	RootPointXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "Point"));
	
	//REF проверить и переименовать процедуры
	ЗаполнитьЭлемент_point(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_ws(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_http(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_analytics(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_standardOdata(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_pool(RootPointXDTO, ДанныеЗаполнения);
	
	ЗаполнитьЭлемент_exitURL(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_progressiveWebApplication(RootPointXDTO, ДанныеЗаполнения);
	ЗаполнитьЭлемент_openID(RootPointXDTO, ДанныеЗаполнения);
	
	ЗаполнитьЭлемент_debug(RootPointXDTO, ДанныеЗаполнения);
	
	ЗаполнитьЭлемент_zones(RootPointXDTO, ДанныеЗаполнения);
	
	ФабрикаXDTO.ЗаписатьXML(ЗаписьXML, RootPointXDTO, "point");
	
	СтрокаXML = ЗаписьXML.Закрыть();
	
	Возврат СтрокаXML;
	
КонецФункции


#КонецОбласти


#Область СлужебныеПроцедурыИФункции


Процедура ЗаполнитьЭлемент_point(PointXDTO, ДанныеЗаполнения)
	
	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();
	СтрокаСоединения = СтрЗаменить(СтрокаСоединения, """", "");
	
	PointXDTO.base = "/" + ДанныеЗаполнения.ИмяБазы;
	PointXDTO.ib = СтрокаСоединения;
	PointXDTO.enable = XMLСтрока(ДанныеЗаполнения.ПубликоватьДоступ);
	
	Если ЗначениеЗаполнено(ДанныеЗаполнения.ФоновыеЗадания) Тогда
		PointXDTO.allowexecutescheduledjobs = ДанныеЗаполнения.ФоновыеЗадания;
	КонецЕсли;
	
	Для Каждого Дистрибутив Из ДанныеЗаполнения.РасположенияДистрибутива Цикл
	
		Если ЗначениеЗаполнено(Дистрибутив.ОперационнаяСистема) 
			И ЗначениеЗаполнено(Дистрибутив.Путь) Тогда
			 PointXDTO.Установить(Дистрибутив.ОперационнаяСистема, Дистрибутив.Путь);
		КонецЕсли;
	
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьЭлемент_ws(PointXDTO, ДанныеЗаполнения)

	WebServicesXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "WebServices"));
	WebServicesXDTO.enable					= XMLСтрока(ДанныеЗаполнения.ПубликоватьWebСервисы);
	WebServicesXDTO.pointEnableCommon		= XMLСтрока(ДанныеЗаполнения.ПубликоватьWebСервисыПоУмолчанию);
	WebServicesXDTO.publishExtensionsByDefault	= XMLСтрока(ДанныеЗаполнения.ПубликоватьWebСервисыРасширений);

	Для Каждого WebСервис Из ДанныеЗаполнения.WebСервисы Цикл
		WSPointXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "WebService"));
		WSPointXDTO.enable			= XMLСтрока(WebСервис.Активность);
		WSPointXDTO.name				= WebСервис.ИмяСервиса;
		WSPointXDTO.alias			= WebСервис.Адрес;
		WSPointXDTO.reuseSessions	= "dontuse";
		WSPointXDTO.sessionMaxAge	= "20";
		WSPointXDTO.poolSize			= "10";
		WSPointXDTO.poolTimeout		= "5";
		
		AccessTokenAuthentication = ПолучитьAccessTokenAuthentication(ДанныеЗаполнения);
		Если AccessTokenAuthentication <> Неопределено Тогда
			WSPointXDTO.accessTokenAuthentication = ПолучитьAccessTokenAuthentication(ДанныеЗаполнения);
		КонецЕсли;
		
		WebServicesXDTO.point.Добавить(WSPointXDTO);
	КонецЦикла;

	PointXDTO.ws = WebServicesXDTO;

КонецПроцедуры // ЗаполнитьЭлемент_ws()

Процедура ЗаполнитьЭлемент_http(PointXDTO, ДанныеЗаполнения)

	HTTPServicesXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "HttpServices"));
	HTTPServicesXDTO.publishByDefault			= XMLСтрока(ДанныеЗаполнения.ПубликоватьHTTPСервисы);
	HTTPServicesXDTO.publishExtensionsByDefault	= XMLСтрока(ДанныеЗаполнения.ПубликоватьHTTPСервисыРасширений);

	Для Каждого HTTPСервис Из ДанныеЗаполнения.HTTPСервисы Цикл
		HTTPPointXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "HttpService"));
		HTTPPointXDTO.enable			= XMLСтрока(HTTPСервис.Активность);
		HTTPPointXDTO.name			= HTTPСервис.ИмяСервиса;
		HTTPPointXDTO.rootUrl		= HTTPСервис.URL;
		HTTPPointXDTO.reuseSessions	= "dontuse";
		HTTPPointXDTO.sessionMaxAge	= "20";
		HTTPPointXDTO.poolSize		= "10";
		HTTPPointXDTO.poolTimeout	= "5";
		
		AccessTokenAuthentication = ПолучитьAccessTokenAuthentication(ДанныеЗаполнения);
		Если AccessTokenAuthentication <> Неопределено Тогда
			HTTPPointXDTO.accessTokenAuthentication = ПолучитьAccessTokenAuthentication(ДанныеЗаполнения);
		КонецЕсли;
		
		HTTPServicesXDTO.service.Добавить(HTTPPointXDTO);
	КонецЦикла;

	PointXDTO.httpServices = HTTPServicesXDTO;

КонецПроцедуры // ЗаполнитьЭлемент_http()

Процедура ЗаполнитьЭлемент_analytics(PointXDTO, ДанныеЗаполнения)
	
	АналитикаXDTO = ПолучитьОписаниеТипаXDTO("Analytics");
	
	Если АналитикаXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	АналитикаXDTO.enable 		= XMLСтрока(ДанныеЗаполнения.ПубликоватьАналитику);
	АналитикаXDTO.sessionMaxAge	= "1200";
	АналитикаXDTO.poolSize		= "500";
	АналитикаXDTO.poolTimeout	= "5";
	
	PointXDTO.analytics = АналитикаXDTO;

КонецПроцедуры // ЗаполнитьЭлемент_analytics()

Процедура ЗаполнитьЭлемент_standardOdata(PointXDTO, ДанныеЗаполнения)
	
	ODataXDTO = ПолучитьОписаниеТипаXDTO("OData");
	
	Если ODataXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ODataXDTO.enable 			= XMLСтрока(ДанныеЗаполнения.ПубликоватьOData);
	ODataXDTO.reuseSessions	= "autouse";
	ODataXDTO.sessionMaxAge	= "20";
	ODataXDTO.poolSize			= "10";
	ODataXDTO.poolTimeout		= "5";
	
	PointXDTO.standardOdata = ODataXDTO;
	
КонецПроцедуры // ЗаполнитьЭлемент_standardOdata()	

Процедура ЗаполнитьЭлемент_pool(PointXDTO, ДанныеЗаполнения)
	
	ПроверяемыеЗначения = Новый Соответствие;
	ПроверяемыеЗначения.Вставить("КоличествоСоединений",				10000);
	ПроверяемыеЗначения.Вставить("ВремяЖизниСоединений",				1200);
	ПроверяемыеЗначения.Вставить("СоединениеЧислоПопыток",				5);
	ПроверяемыеЗначения.Вставить("СоединениеВремяМеджуПопытками",	1000);
	ПроверяемыеЗначения.Вставить("СоединениеВремяОжидания",			500);
	ПроверяемыеЗначения.Вставить("СоединениеТаймаутПроверки",			15000);
	ПроверяемыеЗначения.Вставить("СоединениеПериодПроверки",			3000);
	
	Если ЗначенияЗаполненыПоУмолчанию(ДанныеЗаполнения, ПроверяемыеЗначения) Тогда
		Возврат;
	КонецЕсли;
	
	PoolXDTO = ПолучитьОписаниеТипаXDTO("Pool");
	
	Если PoolXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;

	PoolXDTO.size					= ДанныеЗаполнения.КоличествоСоединений;
	PoolXDTO.maxAge				= ДанныеЗаполнения.ВремяЖизниСоединений;
	PoolXDTO.attempts			= ДанныеЗаполнения.СоединениеЧислоПопыток;
	PoolXDTO.attemptTimeout		= ДанныеЗаполнения.СоединениеВремяМеджуПопытками;
	PoolXDTO.waitTimeout			= ДанныеЗаполнения.СоединениеВремяОжидания;
	PoolXDTO.serverPingTimeout	= ДанныеЗаполнения.СоединениеТаймаутПроверки;
	PoolXDTO.serverPingPeriod	= ДанныеЗаполнения.СоединениеПериодПроверки;
	
	PointXDTO.pool = PoolXDTO;
	
КонецПроцедуры // ЗаполнитьЭлемент_standardOdata()	

Процедура ЗаполнитьЭлемент_progressiveWebApplication(PointXDTO, ДанныеЗаполнения)
	
	Если Не ЗначениеЗаполнено(ДанныеЗаполнения.ИмяВебПриложения) Тогда
		Возврат;
	КонецЕсли;
	
	PWebAppXDTO = ПолучитьОписаниеТипаXDTO("ProgressiveWebApplication");
	
	Если PWebAppXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	PWebAppXDTO.name = XMLСтрока(ДанныеЗаполнения.ИмяВебПриложения);
	
	PointXDTO.progressiveWebApplication = PWebAppXDTO;
	
КонецПроцедуры // ЗаполнитьЭлемент_progressiveWebApplication()	

Процедура ЗаполнитьЭлемент_exitURL(PointXDTO, ДанныеЗаполнения)
	
	Если Не ЗначениеЗаполнено(ДанныеЗаполнения.АдресПерехода) Тогда
		Возврат;
	КонецЕсли;
	
	PointXDTO.exitURL = XMLСтрока(ДанныеЗаполнения.АдресПерехода);
	
КонецПроцедуры // ЗаполнитьЭлемент_exitURL()

Процедура ЗаполнитьЭлемент_openID(PointXDTO, ДанныеЗаполнения)
	
	Если ДанныеЗаполнения.ИспользоватьOpenID = Ложь 
		И ДанныеЗаполнения.ИспользоватьКакOpenIDПровайдера = Ложь Тогда
		Возврат;
	КонецЕсли;
	
	OpenIDXDTO = ПолучитьОписаниеТипаXDTO("OpenID");
	
	Если OpenIDXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ДанныеЗаполнения.ИспользоватьOpenID = Истина Тогда
		OpenIDRelyXDTO = ПолучитьОписаниеТипаXDTO("OpenIDRelyingPartyParams");
		
		Если OpenIDRelyXDTO = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		OpenIDRelyXDTO.url = XMLСтрока(ДанныеЗаполнения.АдресOpenIDПровайдера);
		OpenIDXDTO.rely = OpenIDRelyXDTO;
		
	ИначеЕсли ДанныеЗаполнения.ИспользоватьКакOpenIDПровайдера = Истина Тогда
		
		ProviderXDTO = ПолучитьОписаниеТипаXDTO("OpenIDProviderParams");
		ProviderXDTO.lifetime = XMLСтрока(ДанныеЗаполнения.ВремяЖизниАутентификации);
		
		Для Каждого ЭлементПереадресации Из ДанныеЗаполнения.РазрешенныеАдресаПереадресации Цикл
			ProviderXDTO.returnto.Добавить(XMLСтрока(ЭлементПереадресации));
		КонецЦикла;
		
		OpenIDXDTO.provider = ProviderXDTO;
		
	КонецЕсли;
	
	PointXDTO.openid = OpenIDXDTO;
	
КонецПроцедуры // ЗаполнитьЭлемент_openID()

Процедура ЗаполнитьЭлемент_debug(PointXDTO, ДанныеЗаполнения)
	
	Если Не ЗначениеЗаполнено(ДанныеЗаполнения.Отладка) Тогда
		Возврат;
	КонецЕсли;
	
	DebugXDTO = ПолучитьОписаниеТипаXDTO("Debug");
	
	Если DebugXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	DebugXDTO.enable 	= XMLСтрока(Истина);
	DebugXDTO.protocol	= ДанныеЗаполнения.Отладка;
	DebugXDTO.url		= ДанныеЗаполнения.АдресОтладчика;
	
	PointXDTO.debug = DebugXDTO;

КонецПроцедуры // ЗаполнитьЭлемент_debug()

Процедура ЗаполнитьЭлемент_zones(PointXDTO, ДанныеЗаполнения)

	ZonesXDTO = ПолучитьОписаниеТипаXDTO("ZoneInfos");
	
	Если ZonesXDTO = Неопределено Или ДанныеЗаполнения.РазделителиДанных.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ИмеютсяАктивныеРазделители = Ложь;
	
	Для Каждого РазделительДанных Из ДанныеЗаполнения.РазделителиДанных Цикл
		
		ZoneXDTO = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", "ZoneInfo"));
		
		Если ZoneXDTO = Неопределено Или РазделительДанных.Активность = Ложь Тогда
			Продолжить;
		КонецЕсли;
		
		РазделительЗаполняется = Ложь;
		
		Если РазделительДанных.ЗначениеЗадано = Истина Тогда
			РазделительЗаполняется = Истина;
			ZoneXDTO.value = РазделительДанных.Значение;
		КонецЕсли;
		
		Если РазделительДанных.Указание = Истина Тогда
			РазделительЗаполняется = Истина;
			ZoneXDTO.specify = XMLСтрока(Истина);
		КонецЕсли;
		
		Если РазделительДанных.Безопасное = Истина Тогда
			РазделительЗаполняется = Истина;
			ZoneXDTO.safe = XMLСтрока(Истина);
		КонецЕсли;
		
		Если РазделительЗаполняется Тогда
			ИмеютсяАктивныеРазделители = Истина;
			ZonesXDTO.zone.Добавить(ZoneXDTO);
		КонецЕсли;
		
	КонецЦикла;
	
	Если ИмеютсяАктивныеРазделители Тогда
		PointXDTO.zones = ZonesXDTO;
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьЭлемент_zones()

Функция ЗначенияЗаполненыПоУмолчанию(ДанныеЗаполнения, ПроверяемыеЗначения)

	Для Каждого ЗначениеПроверки Из ПроверяемыеЗначения Цикл
		ЗначениеЗаполнения = Неопределено;
		ДанныеПрисутствуют = ДанныеЗаполнения.Свойство(ЗначениеПроверки.Ключ, ЗначениеЗаполнения);
		Если ДанныеПрисутствуют И ЗначениеЗаполнения <> ЗначениеПроверки.Значение Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;

КонецФункции // ЗначенияЗаполненыПоУмолчанию(ДанныеЗаполнения, ПроверяемыеЗначения)()

Функция ПолучитьAccessTokenAuthentication(ДанныеЗаполнения)
	
	AccessTokenAuthentication = ПолучитьОписаниеТипаXDTO("AccessTokenAuthentication");
	
	Если AccessTokenAuthentication = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Issuers	= ПолучитьОписаниеТипаXDTO("AccessTokenIssuers");
	
	Если Issuers <> Неопределено Тогда
		AccessTokenAuthentication.issuers = Issuers;
	Иначе
		AccessTokenAuthentication.issuers = "";
	КонецЕсли;
	
	AccessTokenAuthentication.accessTokenRecepientName = "";
	
	Возврат AccessTokenAuthentication;

КонецФункции // ПолучитьAccessTokenAuthentication()

Функция ПолучитьОписаниеТипаXDTO(ИмяТипа)

	ОписаниеТипа = ФабрикаXDTO.Тип("http://v8.1c.ru/8.2/virtual-resource-system", ИмяТипа);
	Если ОписаниеТипа = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ФабрикаXDTO.Создать(ОписаниеТипа);

КонецФункции // ПривестиЗначениеТипа()


#КонецОбласти


#Иначе
  ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли

