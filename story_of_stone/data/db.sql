-- MySQL dump 10.13  Distrib 5.7.21, for Linux (x86_64)
--
-- Host: localhost    Database: story_of_stone
-- ------------------------------------------------------
-- Server version	5.7.21-0ubuntu0.17.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `family`
--

DROP TABLE IF EXISTS `family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family` (
  `name` varchar(255) NOT NULL COMMENT '名称',
  `cradle` enum('','金陵','京城') DEFAULT NULL COMMENT '发源地',
  `residence` enum('','金陵','京城') DEFAULT NULL COMMENT '现居住地',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `family`
--
-- ORDER BY:  `name`

LOCK TABLES `family` WRITE;
/*!40000 ALTER TABLE `family` DISABLE KEYS */;
INSERT INTO `family` VALUES
('史家','金陵','金陵'),
('王家','金陵','金陵'),
('王家连宗','',''),
('薛家','金陵','金陵'),
('贾家','金陵','京城'),
('贾家连宗','','');
/*!40000 ALTER TABLE `family` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kinship`
--

DROP TABLE IF EXISTS `kinship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kinship` (
  `subject` varchar(255) NOT NULL COMMENT '主',
  `object` varchar(255) NOT NULL COMMENT '宾',
  `type` enum('父母子女','夫妻') NOT NULL COMMENT '类型',
  `sub_type` enum('亲生','收养','过继','正房','偏房') NOT NULL COMMENT '子类型',
  `note` mediumtext NOT NULL COMMENT '注解',
  PRIMARY KEY (`subject`,`object`,`type`,`sub_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kinship`
--
-- ORDER BY:  `subject`,`object`,`type`,`sub_type`

LOCK TABLES `kinship` WRITE;
/*!40000 ALTER TABLE `kinship` DISABLE KEYS */;
INSERT INTO `kinship` VALUES
('王夫人','贾元春','父母子女','亲生',''),
('王夫人','贾宝玉','父母子女','亲生',''),
('王夫人','贾珠','父母子女','亲生',''),
('贾代化','贾敬','父母子女','亲生','第2回，冷子兴演说'),
('贾代化','贾敷','父母子女','亲生','第2回，冷子兴演说'),
('贾代善','贾政','父母子女','亲生','第2回，冷子兴演说'),
('贾代善','贾敏','父母子女','亲生','第2回，冷子兴演说'),
('贾代善','贾母','夫妻','正房','第2回，冷子兴演说'),
('贾代善','贾赦','父母子女','亲生','第2回，冷子兴演说'),
('贾公','贾源','父母子女','亲生','第2回，冷子兴演说'),
('贾公','贾演','父母子女','亲生','第2回，冷子兴演说'),
('贾政','贾元春','父母子女','亲生',''),
('贾政','贾宝玉','父母子女','亲生',''),
('贾政','贾探春','父母子女','亲生',''),
('贾政','贾环','父母子女','亲生',''),
('贾政','贾珠','父母子女','亲生',''),
('贾敏','林黛玉','父母子女','亲生','第2回，冷子兴演说'),
('贾敬','贾惜春','父母子女','亲生','第2回，冷子兴演说，惜春是贾珍胞妹。'),
('贾敬','贾珍','父母子女','亲生','第2回，冷子兴演说'),
('贾母','贾政','父母子女','亲生','第2回，冷子兴演说。但有争议，http://www.360doc.com/content/16/0131/09/29803221_531819830.shtml'),
('贾母','贾敏','父母子女','亲生','第2回，冷子兴演说'),
('贾母','贾赦','父母子女','亲生','第2回，冷子兴演说。但有各种讨论，https://www.zhihu.com/question/20515515'),
('贾源','贾代善','父母子女','亲生','第2回，冷子兴演说'),
('贾演','贾代化','父母子女','亲生','第2回，冷子兴演说'),
('贾赦','贾琏','父母子女','亲生','第2回，冷子兴演说'),
('贾赦','贾琮','父母子女','亲生','很牵强'),
('赵姨娘','贾探春','父母子女','亲生',''),
('赵姨娘','贾环','父母子女','亲生','');
/*!40000 ALTER TABLE `kinship` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kinship_type`
--

DROP TABLE IF EXISTS `kinship_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kinship_type` (
  `type` enum('父母子女','夫妻') NOT NULL COMMENT '类型',
  `sub_type` enum('亲生','收养','过继','正房','偏房') NOT NULL COMMENT '子类型',
  `male_subject` varchar(255) NOT NULL COMMENT '男主称呼',
  `female_subject` varchar(255) NOT NULL COMMENT '女主称呼',
  `male_object` varchar(255) NOT NULL COMMENT '男宾称呼',
  `female_object` varchar(255) NOT NULL COMMENT '女宾称呼',
  PRIMARY KEY (`type`,`sub_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kinship_type`
--
-- ORDER BY:  `type`,`sub_type`

LOCK TABLES `kinship_type` WRITE;
/*!40000 ALTER TABLE `kinship_type` DISABLE KEYS */;
INSERT INTO `kinship_type` VALUES
('父母子女','亲生','父亲','母亲','儿子','女儿'),
('父母子女','收养','养父','养母','养子','养女'),
('父母子女','过继','父亲','母亲','儿子','女儿'),
('夫妻','正房','丈夫','','','大太太'),
('夫妻','偏房','丈夫','','','姨太太');
/*!40000 ALTER TABLE `kinship_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master`
--

DROP TABLE IF EXISTS `master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `master` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `family` varchar(255) NOT NULL COMMENT '现所属家族',
  `generation` int(10) unsigned NOT NULL COMMENT '在所有家族中拉横是第几代',
  `original_family` varchar(255) NOT NULL COMMENT '原所属家族',
  `dwelling` varchar(255) NOT NULL COMMENT '居所',
  `pay_in_silver` decimal(10,3) NOT NULL COMMENT '每月例银，单位：两',
  `pay_in_coin` decimal(10,3) NOT NULL COMMENT '每月例银，单位：文，一吊钱=1000文',
  `pay_note` mediumtext NOT NULL COMMENT '月例注解',
  `pay_estimated` tinyint(1) NOT NULL COMMENT '月例是否是估算的',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master`
--
-- ORDER BY:  `name`

LOCK TABLES `master` WRITE;
/*!40000 ALTER TABLE `master` DISABLE KEYS */;
INSERT INTO `master` VALUES
('林黛玉','贾家',4,'林家','荣国府-大观园-潇湘馆',2.000,0.000,'第3回，收养后吃穿用度均与其他姑娘相同。第56回，探春说月银是二两。',1),
('贾代化','贾家',2,'','宁国府',0.000,0.000,'',0),
('贾代善','贾家',2,'','荣国府',0.000,0.000,'',0),
('贾元春','贾家',2,'','荣国府',0.000,0.000,'',0),
('贾宝玉','贾家',4,'','荣国府-大观园-怡红院',2.000,0.000,'第51回，给晴雯看病抓了2两的银戥子，但宝玉每月花的钱远远不止这些',1),
('贾惜春','贾家',4,'','荣国府-大观园-蓼风轩(第23回)、暖香坞(第50回)',2.000,0.000,'',0),
('贾探春','贾家',4,'','荣国府-大观园-秋爽斋',2.000,0.000,'',0),
('贾政','贾家',3,'','荣国府-荣禧堂',0.000,0.000,'',0),
('贾敏','林家',3,'贾家','',0.000,0.000,'',0),
('贾敬','贾家',3,'','宁国府',0.000,0.000,'',0),
('贾敷','贾家',3,'','宁国府',0.000,0.000,'',0),
('贾母','贾家',2,'史家','荣国府',20.000,0.000,'第45回，李纨跟凤姐商量诗社的活动经费，凤姐讲李纨跟老太太、太太一样月例了',0),
('贾源','贾家',1,'','荣国府',0.000,0.000,'',0),
('贾演','贾家',1,'','宁国府',0.000,0.000,'',0),
('贾王扁','贾家',4,'','',0.000,0.000,'',0),
('贾环','贾家',4,'','荣国府-东小院',2.000,0.000,'第36回，凤姐说赵姨娘有换兄弟的二两月例银子',0),
('贾珍','贾家',4,'','',0.000,0.000,'',0),
('贾珖','贾家',4,'','',0.000,0.000,'',0),
('贾珠','贾家',2,'','荣国府',0.000,0.000,'',0),
('贾珩','贾家',4,'','',0.000,0.000,'',0),
('贾琏','贾家',4,'','荣国府',0.000,0.000,'',0),
('贾琛','贾家',4,'','',0.000,0.000,'',0),
('贾琮','贾家',4,'','荣国府',0.000,0.000,'',0),
('贾琼','贾家',4,'','',0.000,0.000,'',0),
('贾璘','贾家',4,'','',0.000,0.000,'',0),
('贾芝','贾家',5,'','',0.000,0.000,'',0),
('贾芬','贾家',5,'','',0.000,0.000,'',0),
('贾芳','贾家',5,'','',0.000,0.000,'',0),
('贾菌','贾家',5,'','',0.000,0.000,'',0),
('贾菖','贾家',5,'','',0.000,0.000,'',0),
('贾菱','贾家',5,'','',0.000,0.000,'',0),
('贾萍','贾家',5,'','',0.000,0.000,'',0),
('贾蓁','贾家',5,'','',0.000,0.000,'',0),
('贾藻','贾家',5,'','',0.000,0.000,'',0),
('贾蘅','贾家',5,'','',0.000,0.000,'',0),
('贾赦','贾家',3,'','荣国府-别院',0.000,0.000,'',0);
/*!40000 ALTER TABLE `master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `deduction` tinyint(1) NOT NULL COMMENT '是否是推导出的人物',
  `gender` enum('男','女') NOT NULL COMMENT '性别',
  `age` int(10) unsigned NOT NULL COMMENT '大致年龄',
  `age_note` mediumtext NOT NULL COMMENT '大致年龄的注解',
  `sort_age` double NOT NULL COMMENT '程序排序用年龄，不用于展示',
  `sort_position` double NOT NULL COMMENT '程序排序用的人物地位，不用于展示',
  `family_name` varchar(50) NOT NULL COMMENT '姓',
  `given_name` varchar(150) NOT NULL COMMENT '名',
  `old_name` varchar(255) NOT NULL COMMENT '原名',
  `old_name_note` varchar(255) NOT NULL COMMENT '原名注解',
  `nick_1` varchar(255) NOT NULL COMMENT '诨名1',
  `nick_note_1` mediumtext NOT NULL COMMENT '诨名1注解',
  `nick_2` varchar(255) NOT NULL COMMENT '诨名2',
  `nick_note_2` mediumtext NOT NULL COMMENT '诨名2注解',
  `nick_3` varchar(255) NOT NULL COMMENT '诨名3',
  `nick_note_3` mediumtext NOT NULL COMMENT '诨名3注解',
  `nick_4` varchar(255) NOT NULL COMMENT '诨名4',
  `nick_note_4` mediumtext NOT NULL COMMENT '诨名4注解',
  `title_1` varchar(255) NOT NULL COMMENT '尊称1',
  `title_note_1` mediumtext NOT NULL COMMENT '尊称1注解',
  `title_2` varchar(255) NOT NULL COMMENT '尊称2',
  `title_note_2` mediumtext NOT NULL COMMENT '尊称2注解',
  `title_3` varchar(255) NOT NULL COMMENT '尊称3',
  `title_note_3` mediumtext NOT NULL COMMENT '尊称3注解',
  `title_4` varchar(255) NOT NULL COMMENT '尊称4',
  `title_note_4` mediumtext NOT NULL COMMENT '尊称4注解',
  `first_action_chapter` int(10) unsigned NOT NULL COMMENT '首次活动回目，本人活动出场回目',
  `first_action_note` mediumtext NOT NULL COMMENT '首次活动注解',
  `first_refer_chapter` int(10) unsigned NOT NULL COMMENT '首次提及回目：本人未出场，但先被别人提到了',
  `first_refer_note` mediumtext NOT NULL COMMENT '首次提及注解',
  `first_name_chapter` int(10) unsigned NOT NULL COMMENT '首次称呼回目：人物的名字出现位置可能和首次出场不同，也可能和首次提及回目不同',
  `first_name_note` mediumtext NOT NULL COMMENT '首次称呼注解',
  `die_chapter` int(10) unsigned NOT NULL COMMENT '死亡回目',
  `die_note` mediumtext NOT NULL COMMENT '死亡注解',
  `dead` tinyint(1) NOT NULL COMMENT '至大观园时是否已经死亡',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--
-- ORDER BY:  `name`

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES
('林黛玉',0,'女',13,'http://blog.sina.com.cn/s/blog_6755590d0102va0e.html',13.5,555,'林','黛玉','','','颦颦/颦儿/颦丫头','第3回，宝玉初见取表字颦颦','病西施','第65回，兴儿对二尤介绍黛玉','潇湘妃子','第37回，诗社里新取的笔名','','','林姑娘','','','','','','','',3,'黛玉进入荣国府',2,'陈述贾雨村做林府西宾',2,'陈述贾雨村做林府西宾',0,'',0),
('袭人',0,'女',16,'https://www.douban.com/group/topic/28547104/',16.5,333,'花','袭人','花珍珠','第23回，贾政问王夫人袭人是谁，宝玉解释道','','','','','','','','','花大姑娘','','','','','','','',3,'黛玉进入荣国府，袭人劝慰黛玉',3,'',3,'',0,'',0),
('贾代化',0,'男',70,'纯拍脑袋瞎猜',70.5,886,'贾','代化','','','','','','','','','','','','','','','','','','',0,'0',2,'冷子兴演说荣国府时提到',2,'',0,'',1),
('贾代善',0,'男',68,'纯拍脑袋瞎猜',68.3,885,'贾','代善','','','','','','','','','','','','','','','','','','',0,'0',2,'冷子兴演说荣国府时提到',2,'',0,'',1),
('贾元春',0,'女',25,'元春年龄比较乱，http://ibekolu.blogchina.com/1586561.html',25,888,'贾','元春','','','','','','','','','','','','','','','','','','',18,'元春归省荣国府',2,'冷子兴演说荣国府时提到贾珠是王夫人第二胎',0,'',0,'',1),
('贾公',1,'男',100,'',100,999,'贾','','','','','','','','','','','','','','','','','','','',0,'',0,'',0,'',0,'',1),
('贾宝玉',0,'男',14,'http://blog.sina.com.cn/s/blog_6755590d0102va0e.html',14.5,666,'贾','宝玉','','','怡红公子','第37回，诗社里新取的笔名','绛洞花王','第37回，诗社里李纨提到的旧号','槛内人','第63回，给妙玉回帖中署名','','','宝二爷','','','','','','','',3,'黛玉进入荣国府初见宝玉',2,'冷子兴演说荣国府时提到',2,'冷子兴演说荣国府时提到',0,'',0),
('贾惜春',0,'女',12,'https://tieba.baidu.com/p/2542784236?red_tag=2408789060',12,400,'贾','惜春','','','','','','','','','','','四姑娘','','','','','','','',10,'璜大奶奶和金氏见了尤氏，正好贾珍也进屋',2,'冷子兴说道四小姐惜春是珍爷胞妹',2,'',0,'',0),
('贾探春',0,'女',13,'跟黛玉、湘云差不多，难分清楚。讨论也很多。',13.5,555,'贾','探春','','','','','','','','','','','蕉下客','第37回，诗社里新取的笔名','','','','','','',18,'元春归省荣国府',2,'冷子兴演说荣国府时提到贾珠是王夫人第二胎',0,'',0,'',1),
('贾政',0,'男',48,'纯粹拍脑袋瞎猜。第33回，贾政打宝玉，王夫人说如今已将五十岁的人。',48,800,'贾','政','','','政老爹','第2回，冷子兴演说中称贾政为政老爹','','','','','','','','','','','','','','',9,'宝玉进学堂前，贾政训话',2,'冷子兴演说荣国府时提到代善次子是贾政',2,'',0,'',0),
('贾敏',0,'女',47,'年龄比贾政小。第2回，林如海40岁时，黛玉5岁。至大观园时，黛玉12、13岁。',47,700,'贾','敏','','','','','','','','','','','','','','','','','','',0,'',2,'冷子兴说道贾敏',2,'',0,'',1),
('贾敬',0,'男',54,'纯粹拍脑袋瞎猜',54.5,880,'贾','敬','','','','','','','','','','','太爷','第11回，贾敬生日，各人口中都称他太爷','','','','','','',11,'贾敬生日，贾蓉跟贾敬有些交流',2,'冷子兴演说荣国府时提到贾代化次子贾敬袭了官，但一味好道',2,'',0,'',0),
('贾敷',0,'男',55,'纯粹拍脑袋瞎猜',55,880,'贾','敷','','','','','','','','','','','','','','','','','','',0,'',2,'冷子兴演说荣国府时提到贾代化长子贾敷七八岁就死了',2,'',0,'',1),
('贾母',0,'女',68,'第39回，刘姥姥说自己75岁，贾母说比自己大好几岁',68,880,'史','','','','','','','','','','','','老祖宗','','老太太','','史太君','','','',3,'黛玉进荣国府见贾母',2,'冷子兴演说荣国府时提到贾代善娶了史侯家的小姐为妻',0,'',0,'',0),
('贾源',0,'男',85,'纯拍脑袋瞎猜',85.3,888,'贾','源','','','','','','','','','','','荣国公','','','','','','','',0,'0',2,'冷子兴演说荣国府时提到',2,'',0,'',1),
('贾演',0,'男',85,'纯拍脑袋瞎猜',85.5,887,'贾','演','','','','','','','','','','','宁国公','','','','','','','',0,'0',2,'冷子兴演说荣国府时提到',2,'',0,'',1),
('贾王扁',0,'男',0,'',0,160,'贾','王扁','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾环',0,'男',13,'第78回。https://tieba.baidu.com/p/681397160?red_tag=3245362885',13.5,444,'贾','环','','','','','','','','','','','','','','','','','','',20,'贾环赌钱耍赖',18,'元妃省亲，贾环染病未痊',18,'',0,'',0),
('贾珍',0,'男',39,'第2回，贾雨村说黛玉5岁，冷子兴说贾蓉16岁。那推算下，等黛玉长到14岁时，贾蓉贾蓉25岁，那贾珍可能40了。第76回，其妻尤氏说本四十岁的人了。',39,680,'贾','珍','','','','','','','','','','','族长','第4回，薛蟠进贾府后被引诱的更坏了，解释说贾珍这族长管理的不成样子。','大爷','第14回，王熙凤跟宁国府众仆人说辛苦下，事情完了你们家大爷会赏。','','','','',10,'璜大奶奶和金氏见了尤氏，正好贾珍也进屋。',2,'冷子兴说道贾敬早年留下一子贾珍',2,'',0,'',0),
('贾珖',0,'男',0,'',0,158,'贾','珖','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾珠',0,'男',28,'第2回，冷子兴说贾珠不到20生贾兰',28,670,'贾','珠','','','','','','','','','','','','','','','','','','',0,'',2,'冷子兴演说荣国府时提到贾珠是王夫人头胎',0,'',0,'',1),
('贾珩',0,'男',0,'',0,159,'贾','珩','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾琏',0,'男',29,'第2回，冷子兴推演时黛玉5岁，贾琏已经二十来往.至大观园黛玉13岁时，贾琏至少也29岁了。',29,666,'贾','琏','','','','','','','','','','','琏二爷','','','','','','','',4,'薛蟠进荣国府，贾琏引着拜见贾赦',2,'冷子兴说贾琏是贾政长子',2,'',0,'',0),
('贾琛',0,'男',0,'',0,158,'贾','琛','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾琮',0,'男',13,'年龄可能跟贾环差不多。http://www.guoxue123.com/hongxue/0001/hlwy/074.htm',13,333,'贾','琮','','','','','','','','','','','','','','','','','','',6,'薛蟠进荣国府，贾琏引着拜见贾赦',2,'冷子兴说贾琏是贾政长子',2,'',0,'',0),
('贾琼',0,'男',0,'',0,150,'贾','琼','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾璘',0,'男',0,'',0,157,'贾','璘','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾芝',0,'男',0,'',0,121,'贾','芝','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾芬',0,'男',0,'',0,124,'贾','芬','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾芳',0,'男',0,'',0,123,'贾','芳','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾菌',0,'男',0,'',0,122,'贾','菌','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾菖',0,'男',0,'',0,130,'贾','菖','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾菱',0,'男',0,'',0,129,'贾','菱','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾萍',0,'男',0,'',0,127,'贾','萍','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾蓁',0,'男',0,'',0,128,'贾','蓁','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾藻',0,'男',0,'',0,126,'贾','藻','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾蘅',0,'男',0,'',0,125,'贾','蘅','','','','','','','','','','','','','','','','','','',0,'',13,'参加秦可卿丧礼',13,'',0,'',0),
('贾赦',0,'男',49,'纯粹拍脑袋瞎猜。第11回贾珍称邢夫人、王夫人为婶子，说明贾赦贾政都比贾敬小。',49,780,'贾','赦','','','','','','','','','','','太爷','第11回，贾敬生日，各人口中都称他太爷','','','','','','',11,'贾敬生日，贾蓉跟贾敬有些交流',2,'冷子兴演说荣国府时提到贾代化次子贾敬袭了官，但一味好道',2,'',0,'',0);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servant`
--

DROP TABLE IF EXISTS `servant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servant` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `family` varchar(255) NOT NULL COMMENT '现所属家族',
  `job_description` mediumtext NOT NULL COMMENT '工作描述',
  `serve` varchar(255) NOT NULL COMMENT '侍奉对象',
  `pay_in_silver` decimal(10,3) NOT NULL COMMENT '每月例银，单位：两',
  `pay_in_coin` decimal(10,3) NOT NULL COMMENT '每月例银，单位：文，一吊钱=1000文',
  `pay_note` mediumtext NOT NULL COMMENT '月例注解',
  `pay_estimated` tinyint(1) NOT NULL COMMENT '月例是否是估算的',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servant`
--
-- ORDER BY:  `name`

LOCK TABLES `servant` WRITE;
/*!40000 ALTER TABLE `servant` DISABLE KEYS */;
INSERT INTO `servant` VALUES
('袭人','贾家','大丫头','贾宝玉',2.000,1000.000,'第35回，原本从贾母领一两月例，王夫人改为从自己这里领二两银子一吊钱',0);
/*!40000 ALTER TABLE `servant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_position`
--

DROP TABLE IF EXISTS `social_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `social_position` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `nobility_rank` enum('','公','候','伯','子','男') DEFAULT NULL COMMENT '爵位级别',
  `nobility_title` varchar(255) NOT NULL COMMENT '爵位名称',
  `nobility_note` mediumtext NOT NULL COMMENT '爵位注解',
  `official_rank` int(10) unsigned NOT NULL DEFAULT '999' COMMENT '官位品级',
  `official_title` varchar(255) NOT NULL COMMENT '官位名称',
  `official_note` mediumtext NOT NULL COMMENT '官位注解',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_position`
--
-- ORDER BY:  `name`

LOCK TABLES `social_position` WRITE;
/*!40000 ALTER TABLE `social_position` DISABLE KEYS */;
INSERT INTO `social_position` VALUES
('贾代化','候','一等神威将军','降级袭爵。第13回，贾蓉的履历给戴权看，看到代化的官爵。',0,'京营节度使','第13回，贾蓉的履历给戴权看，看到代化的官爵。'),
('贾代善','公','荣国公','第29回，张道士说宝玉跟荣国公是一个模子里刻出来的，而贾母又说，除了宝玉，没一个人像他爷爷。',0,'',''),
('贾元春','','贤德妃','',0,'凤藻宫尚书',''),
('贾政','候','','父亲代善是国公，贾政降级袭爵',5,'工部员外郎','第3回，林如海向贾雨村介绍贾政时提到'),
('贾敬','伯','','',5,'','第63回，死亡时追赐'),
('贾源','公','荣国公','',0,'',''),
('贾演','公','宁国公','',0,'',''),
('贾珍','子','三品爵威烈将军','降级袭爵。第13回，贾蓉的履历给戴权看，看到贾珍的官爵。',0,'',''),
('贾琏','伯','','降级袭爵',5,'同知','第2回，冷子兴演说将贾琏捐了个官'),
('贾蓉','男','','降级袭爵',0,'江南江宁府江宁县监生','第13回，贾蓉的履历给戴权看，看到贾蓉的官位。'),
('贾赦','','一等将军','第2回，冷子兴说贾赦袭了贾代善官职',0,'','');
/*!40000 ALTER TABLE `social_position` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
