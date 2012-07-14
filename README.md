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

    sudo apt-get install postgresql
    rake data:generate
    cp data /tmp
    copy all your data files (received from dropbox) to /tmp so Postgres can load them without issue

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

	CREATE TABLE authors (id integer, forename varchar(255), surname varchar(255));
	COPY authors FROM '/tmp/authors' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE publication_authors (publication_id varchar(50), author_id integer);
	COPY publication_authors FROM '/tmp/publication_authors' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE journals (id integer, name varchar(255));
	COPY journals FROM '/tmp/journals' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE countries (id integer, name varchar(255));
	COPY countries FROM '/tmp/countries' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_countries (publication_id varchar(50), country_id integer, nbr_of_readers int);
	COPY reader_countries FROM '/tmp/reader_countries' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_academic_status (publication_id varchar(50), academic_status_id integer, nbr_of_readers int);
	COPY reader_academic_status FROM '/tmp/reader_academic_status' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_disciplines (publication_id varchar(50), discipline_id integer, nbr_of_readers int);
	COPY reader_disciplines FROM '/tmp/reader_disciplines' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE publication_details (id varchar(50), title varchar(255), primary_author_id integer, readers integer, publication_id integer);
	COPY publication_details FROM '/tmp/publication_details' DELIMITER E'\t' CSV HEADER;
