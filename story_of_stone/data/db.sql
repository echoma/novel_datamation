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
('林黛玉','贾家',4,'','潇湘馆',2.000,0.000,'第3回，收养后吃穿用度均与其他姑娘相同',1),
('贾宝玉','贾家',4,'','怡红院',2.000,0.000,'第51回，给晴雯看病抓了2两的银戥子，但宝玉每月花的钱远远不止这些',1);
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
('林黛玉',0,'女',14,'http://blog.sina.com.cn/s/blog_6755590d0102va0e.html',14.3,555,'林','黛玉','','','颦颦/颦儿/颦丫头','第3回，宝玉初见取表字颦颦','病西施','第65回，兴儿对二尤介绍黛玉','潇湘妃子','第37回，诗社里新取的笔名','','','林姑娘','','','','','','','',3,'黛玉进入荣国府',2,'陈述贾雨村做林府西宾',2,'陈述贾雨村做林府西宾',0,''),
('袭人',0,'女',16,'https://www.douban.com/group/topic/28547104/',16.5,333,'花','袭人','花珍珠','第23回，贾政问王夫人袭人是谁，宝玉解释道','','','','','','','','','花大姑娘','','','','','','','',3,'黛玉进入荣国府，袭人劝慰黛玉',3,'',3,'',0,''),
('贾宝玉',0,'男',14,'http://blog.sina.com.cn/s/blog_6755590d0102va0e.html',14.5,666,'贾','宝玉','','','怡红公子','第37回，诗社里新取的笔名','绛洞花王','第37回，诗社里李纨提到的旧号','槛内人','第63回，给妙玉回帖中署名','','','宝二爷','','','','','','','',3,'黛玉进入荣国府初见宝玉',2,'冷子兴演说荣国府时提到',2,'冷子兴演说荣国府时提到',0,'');
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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
