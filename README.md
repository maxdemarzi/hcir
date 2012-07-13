hcir
====

HCIR Challenge Project - https://sites.google.com/site/hcirworkshop/hcir-2012/challenge

Cleaning Data
-------------

    tr -s '\r' ' ' < profiles > profiles2
    tr -s '"' ' ' < profiles2 > profiles3
    tr -s '"' ' ' < public_groups > public_groups2

Loading Data
------------

	CREATE TABLE academic_status (id integer, name varchar(255));
	COPY academic_status FROM '/tmp/academic_status' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE contacts (id1 integer, id2 integer);
	COPY contacts FROM '/tmp/contacts' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE disciplines (id integer, name varchar(255));
	COPY disciplines FROM '/tmp/disciplines' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE profiles (id integer, firstname varchar(255), lastname varchar(255), research_interests text, main_discipline_id integer, biographical_info text);
	COPY profiles FROM '/tmp/profiles3' DELIMITER E'\t' CSV HEADER ESCAPE '\';
	
	CREATE TABLE public_group_members (profile_id integer, group_id integer);
	COPY public_group_members FROM '/tmp/public_group_members' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE public_groups (id integer, name varchar(255));
	COPY public_groups FROM '/tmp/public_groups2' DELIMITER E'\t' CSV HEADER;
