DROP TABLE IF EXISTS `family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `family` (
  `name` varchar(255) NOT NULL COMMENT '名称',
  `branch` enum('正','旁','连宗') COMMENT '分支',
  `cradle` enum('','金陵','京城') DEFAULT NULL COMMENT '发源地',
  `residence` enum('','金陵','京城') DEFAULT NULL COMMENT '现居住地',
  PRIMARY KEY (`name`, `branch`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `family`
--
-- ORDER BY:  `name`

LOCK TABLES `family` WRITE;
/*!40000 ALTER TABLE `family` DISABLE KEYS */;
INSERT INTO `family` VALUES
('史家','正','金陵','金陵'),
('王家','正','金陵','金陵'),
('王家','连宗','',''),
('薛家','正','金陵','金陵'),
('贾家','正','金陵','京城'),
('贾家','旁','金陵','京城'),
('贾家','连宗','','');
/*!40000 ALTER TABLE `family` ENABLE KEYS */;
UNLOCK TABLES;

alter table family add column branch enum('正','旁','连宗');

drop table `person`;
CREATE TABLE `person` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `deduction` tinyint(1) NOT NULL COMMENT '是否是推导出的人物',
  `type` enum('主子','仆人','皇族'),
  `level` tinyint(1) NOT NULL COMMENT '级别。如果是主子就表明第几代；如果是仆人就是第几等',
  `gender` enum('男','女') NOT NULL COMMENT '性别',
  `sort_age` double NOT NULL COMMENT '年龄排序值',
  `sort_position` double NOT NULL COMMENT '地位排序值',
  `dead` tinyint(1) NOT NULL COMMENT '至红楼14年时是否已经死亡',
  `family` varchar(255) NOT NULL COMMENT '现所属家族',
  `branch` varchar(255) NOT NULL COMMENT '现所属家族分支',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into person select name,deduction,'主子',0,gender,sort_age,sort_position,dead,'贾家','正' from sos.person;
update person set type='仆人' where name in (select name from sos.servant);
update person set level=1 where name in (select name from sos.servant where job_description='大丫头');
update person set level=2 where name in (select name from sos.servant where job_description='小丫头');
update person p join sos.master m on m.name=p.name set p.level=m.generation;
update person set family='王家' where name in (select name from sos.master where family='王家');
update person set family='史家' where name in (select name from sos.master where family='史家');

CREATE TABLE `allowance_type` (
  `name` varchar(255) NOT NULL COMMENT '月例类型名称',
  `silver` decimal(10,3) NOT NULL COMMENT '以银两形式发放的量，单位：两',
  `coin` decimal(10,3) NOT NULL COMMENT '以制钱形式发放的量，单位：文，一吊钱=1000文',
  `note` mediumtext NOT NULL COMMENT '月例注解',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into allowance_type values
('大主子一等丫鬟','1','0','第36回，老太太屋里几个大丫头都是一两，王夫人说金钏死了省下一两银子，说明金钏也是大丫头。'),
('小主子一等丫鬟','0','1000','第36回，就是晴雯麝月等七个大丫头，每月人各月钱一吊，佳蕙等八个小丫头，每月人各月钱五百'),
('二等丫鬟','0','500','第36回，佳蕙等八个小丫头，每月人各月钱五百。从旧年他们外头商议的，姨娘们每位的丫头分例减半，人各五百钱。'),
('袭人','2','1000','第35回，原本从贾母领一两月例，王夫人改为从自己这里领二两银子一吊钱'),
('太太','20','0','第45回，李纨跟凤姐商量诗社的活动经费，凤姐讲李纨跟老太太、太太一样月例了。第36回，王夫人说自己的月例是20两。'),
('李纨','20','0','正房太太10两，贾母又特别拨了10两'),
('奶奶','3.3','0','第45回，王熙凤对李纨说：你一个月十两银子的月钱，比我们多两倍银子'),
('姨娘','2','0','第三十六回，王夫人问凤姐，赵姨娘与周姨娘的月例是多少，凤姐回答：“那是定例，每人二两。”');

CREATE TABLE `serve` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `serve` varchar(255) NOT NULL COMMENT '侍奉对象',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `allowance` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `type` varchar(255) NOT NULL COMMENT '月例类型名称',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into serve select name,serve from sos.servant where serve!='';

CREATE TABLE `nick` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `nick` varchar(255) NOT NULL COMMENT '诨名',
  `note` mediumtext NOT NULL COMMENT '注解',
  PRIMARY KEY (`name`,`nick`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into nick select name,nick_1,nick_note_1 from sos.person where nick_1!='';
insert into nick select name,nick_2,nick_note_2 from sos.person where nick_2!='';
insert into nick select name,nick_3,nick_note_3 from sos.person where nick_3!='';
insert into nick select name,nick_4,nick_note_4 from sos.person where nick_4!='';

CREATE TABLE `title` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `title` varchar(255) NOT NULL COMMENT '尊称',
  `note` mediumtext NOT NULL COMMENT '注解',
  PRIMARY KEY (`name`,`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into title select name,title_1,title_note_1 from sos.person where title_1!='';
insert into title select name,title_2,title_note_2 from sos.person where title_2!='';
insert into title select name,title_3,title_note_3 from sos.person where title_3!='';
insert into title select name,title_4,title_note_4 from sos.person where title_4!='';

CREATE TABLE `person_ext` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `age` int(10) unsigned NOT NULL COMMENT '大致年龄',
  `age_note` mediumtext NOT NULL COMMENT '大致年龄的注解',
  `family_name` varchar(50) NOT NULL COMMENT '姓',
  `old_name` varchar(255) NOT NULL COMMENT '原名',
  `old_name_note` varchar(255) NOT NULL COMMENT '原名注解',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into person_ext select name,age,age_note,family_name,old_name,old_name_note from sos.person where age>0 or length(old_name)>0;

drop table person_action;
CREATE TABLE `person_action` (
  `name` varchar(255) NOT NULL COMMENT '称呼',
  `chap` int(10) unsigned NOT NULL COMMENT '首次活动回目，本人活动出场回目',
  `note` mediumtext NOT NULL COMMENT '首次活动注解',
  `refer_chap` int(10) unsigned NOT NULL COMMENT '首次提及回目：本人未出场，但先被别人提到了',
  `refer_note` mediumtext NOT NULL COMMENT '首次提及注解',
  `name_chap` int(10) unsigned NOT NULL COMMENT '首次称呼回目：人物的名字出现位置可能和首次出场不同，也可能和首次提及回目不同',
  `name_note` mediumtext NOT NULL COMMENT '首次称呼注解',
  `die_chap` int(10) unsigned NOT NULL COMMENT '死亡回目',
  `die_note` mediumtext NOT NULL COMMENT '死亡注解',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into person_action select name,first_action_chapter,first_action_note,first_refer_chapter,first_refer_note,first_name_chapter,first_name_note,die_chapter,die_note from sos.person where first_action_chapter>0 or first_refer_chapter>0 or first_name_chapter or die_chapter>0;

drop table servant;
drop table master;