-- CSE2/4DBF 2022
-- eventSchema.sql

-- Drop table statements to clear any tables with the same names as
-- those in the Event Schema

DROP TABLE Venues CASCADE CONSTRAINTS PURGE;
DROP TABLE Promoters CASCADE CONSTRAINTS PURGE;
DROP TABLE Clients CASCADE CONSTRAINTS PURGE;
DROP TABLE Sponsors CASCADE CONSTRAINTS PURGE;
DROP TABLE HireCompany CASCADE CONSTRAINTS PURGE;
DROP TABLE ServiceCompany CASCADE CONSTRAINTS PURGE;
DROP TABLE Equipments CASCADE CONSTRAINTS PURGE;
DROP TABLE Events CASCADE CONSTRAINTS PURGE;
DROP TABLE Tickets CASCADE CONSTRAINTS PURGE;
DROP TABLE EventSponsors CASCADE CONSTRAINTS PURGE;
DROP TABLE EventServices CASCADE CONSTRAINTS PURGE;
DROP TABLE EventEquipments CASCADE CONSTRAINTS PURGE;
DROP TABLE EventVenues CASCADE CONSTRAINTS PURGE;

-- Venue Table
-- Stores the details of venues where events may be held

CREATE TABLE Venues
(venueID		VARCHAR2(6)	NOT NULL,
venueName		VARCHAR2(50),
streetAddress	VARCHAR2(50),
suburb		VARCHAR2(30),
postcode		CHAR(4),
venueCapacity	NUMBER(4)	NOT NULL,
costPerDay		NUMBER(7,2),
venueManager	VARCHAR2(50),
managerPhoneNo	VARCHAR2(15),
PRIMARY KEY (venueID));

INSERT INTO Venues
VALUES
('V00001', 'Town Hall', '15 High St', 'Local Town', '1001', 800, 650.00, 'Sean O''Riley', '9333 2498');

INSERT INTO Venues
VALUES
('V00002', 'Lyndhurst Street Community Centre', '12 Lyndhurst St', 'Local Town', '1001', 170, 310.00, 'Kylie Ong', '9333 1212');

INSERT INTO Venues
VALUES
('V00003', 'Local Town Community Theatre', '146 Main Rd', 'Local Town', '1001', 650, 1500.00, 'James McPhee', '9333 8569');

INSERT INTO venues
VALUES
('V00004', 'Grange Road Scout Hall', '6 Grange Rd', 'Local Town', '1001', 75, 50.00, 'Thomas Smith', '9333 5674');

INSERT INTO venues
VALUES
('V00005', 'Market Hill Scout Hall', '15 Plenty Ave', 'Market Hill', '1002', 120, 75.00, 'Binh Nguyen', '9334 2378');

INSERT INTO venues
VALUES
('V00006', 'Davis Street Community Centre', '1 Davis St', 'Market Hill', '1002', 250, 125.00, 'Dina Thomopolous', '9334 2991');

INSERT INTO Venues
VALUES
('V00007', 'St Patricks Church Hall', '14 Jamieson Ave', 'Fisherman''s Bend', '1003', 120, 70.00, 'Seamus Mullen', '9335 8868');

INSERT INTO venues
VALUES
('V00008', 'Fisherman''s Function Centre', '123 High St', 'Fisherman''s Bend', '1003', 500, 1750.00, 'Anil Singh', '9335 8228');

INSERT INTO Venues
VALUES
('V00009', 'Fisherman''s Bend Hall', '77 Mahoney Rd', 'Fisherman''s Bend', '1003', 130, 115.00, 'Jennifer Warhurst', '9335 8734');

INSERT INTO Venues
VALUES
('V00010', 'Local Town Video Conference Centre', '140 Main Rd', 'Local Town', '1001', 50, 800.00, 'Justin Sedgewick', '9333 0090');

-- Promoter Table
-- Stores the details of event promoters

CREATE TABLE Promoters
(promoterID			VARCHAR2(6)		NOT NULL,
promoterBusinessName	VARCHAR2(50)	NOT NULL,
streetAddress		VARCHAR2(50),
suburb			VARCHAR2(30),
postcode			VARCHAR2(4),
promoterPhoneNo		VARCHAR2(15),
promoterFaxNo		VARCHAR2(15),
contactPerson		VARCHAR2(50),
PRIMARY KEY (promoterID));

INSERT INTO Promoters
VALUES
('P00001', 'Walter''s Meats', '23 High St', 'Local Town', '1001', '9333 3331', '9333 3332', 'Walter Dreyer');

INSERT INTO Promoters
VALUES
('P00002', 'Clara''s Cafe', '27 High St', 'Local Town', '1001', '9333 3221', '9333 3222', 'Clara Thompson');

INSERT INTO Promoters
VALUES
('P00003', 'Tandoori Temptations', '31 High St', 'Local Town', '1001', '9333 3111', '9333 3112', 'Gaurav Singh');

INSERT INTO Promoters
VALUES
('P00004', 'Vietnamese Cuisine', '37 High St', 'Local Town', '1001', '9333 3001', '9333 3002', 'Anna Nguyen');

INSERT INTO Promoters
VALUES
('P00005', 'Coffee by the Lake', '79 Mahoney Rd', 'Fisherman''s Bend', '1003', '9335 2221', '9335 2222', 'Maree Cotti');

-- Client Table
-- Stores the details of clients of Local Events. These are the people
-- who request Local Events to organise an event for them.

CREATE TABLE Clients
(clientID			VARCHAR2(6)		NOT NULL,
clientCompanyName		VARCHAR2(50)		NOT NULL,
streetAddress			VARCHAR2(50),
suburb				VARCHAR2(30),
postcode			CHAR(4),
clientContactFirstName		VARCHAR2(30),
clientContactLastName		VARCHAR2(40),
clientContactPhoneNo		VARCHAR2(15),
clientContactFaxNo		VARCHAR2(15),
PRIMARY KEY (clientID));

INSERT INTO Clients
VALUES
('C00001', 'Pearson''s Real Estate', '23 High St', 'Local Town', '1001', 'Jamie', 'Pearson', '9333 1321', '9333 1323');

INSERT INTO Clients
VALUES
('C00002', 'Bayman''s Business Group', '28 Main Rd', 'Local Town', '1001', 'Bruce', 'Bayman', '9333 5675', '9333 5676');

INSERT INTO Clients
VALUES
('C00003', 'Local Town Council', '17 High St', 'Local Town', '1001', 'Alicia', 'May', '9333 0120', '9333 0121');

INSERT INTO Clients
VALUES
('C00004', 'Market Hill Council', '15 Davis St', 'Market Hill', '1002', 'Penny', 'Wong', '9334 0120', '9334 0121');

INSERT INTO Clients
VALUES
('C00005', 'Fisherman''s Bend Council', '55 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Andrew', 'Davidson', '9335 0120', '9335 0121');

INSERT INTO Clients
VALUES
('C00006', 'Market Masqueraders', '12 Conceal Crt', 'Market Hill', '1002', 'Gabrielle', 'Martinez', '9334 2232', NULL);

INSERT INTO Clients
VALUES
('C00007', 'Thespian Theatre', '15 Shakespeare Dr', 'Fisherman''s Bend', '1003', 'Terrapin', 'Evans', '9335 8978', NULL);

INSERT INTO Clients
VALUES
('C00008', 'Babette''s Ballet School', '17 Renaissance Crt', 'Market Hill', '1002', 'Frances', 'Sabatini', '9334 7773', '9334 7774');

INSERT INTO Clients
VALUES
('C00009', 'School of Song and Dance', '9 Broadway Ave', 'Fisherman''s Bend', '1003', 'Jasmina', 'Pardede', '9335 7629', '9335 7628');

INSERT INTO Clients
VALUES
('C00010', 'Fisherman''s Bend Football Club', '70 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Nathan', 'Jackson', '9335 9901', NULL);

INSERT INTO Clients
VALUES
('C00011', 'Access Accounting', '16 Lyndhurst St', 'Local Town', '1001', 'Sunil', 'Kumble', '9333 0023', '9333 0024');

INSERT INTO Clients
VALUES
('C00012', 'Local Town Athletics League', '6 Oval Rd', 'Local Town', '1001', 'John', 'Mitropolous', '9333 0675', '9333 0677');

INSERT INTO Clients
VALUES
('C00013', 'Fisherman''s Bend Choral Society', '5 Baroque Crt', 'Fisherman''s Bend', '1003', 'David', 'Evans', '9335 9347', NULL);

INSERT INTO Clients
VALUES
('C00014', 'Local Town Brass Band', '10 Tuba Tce', 'Local Town', '1001', 'Trent', 'Davies', '9333 1414', NULL);

INSERT INTO Clients
VALUES
('C00015', 'Fisherman''s Bend Bee Keeping Association', '6 Apiary Lane', 'Fisherman''s Bend', '1003', 'William', 'Blackwell', '9335 0021', NULL);

-- Sponsor Table
-- This table stores the details of the businesses who sponsor events.

CREATE TABLE Sponsors
(businessID			VARCHAR2(6)		NOT NULL,
businessName		VARCHAR2(50)	NOT NULL,
streetAddress		VARCHAR2(50),
suburb			VARCHAR2(30),
postcode			CHAR(4),
contactName			VARCHAR2(50),
contactPhoneNo		VARCHAR2(15),
contactFaxNo		VARCHAR2(15),
PRIMARY KEY (businessID));

INSERT INTO Sponsors
VALUES
('SP0001', 'Local Town IGA', '25 High St', 'Local Town', '1001', 'Dennis Epstein', '9333 5550', '9333 5551');

INSERT INTO Sponsors
VALUES
('SP0002', 'Gordon''s Greengrocers', '29 High St', 'Local Town', '1001', 'Gordon Greene', '9333 3330', '9333 3331');

INSERT INTO Sponsors
VALUES
('SP0003', 'Dehlia''s Deli', '30 High St', 'Local Town', '1001', 'Dehlia Bree', '9333 2223', '9333 2221');

INSERT INTO Sponsors
VALUES
('SP0004', 'Fisherman''s Bend Bottle Shop', '68 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Jim Daniels', '9335 0103', '9335 0104');

INSERT INTO Sponsors
VALUES
('SP0005', 'Helga''s Haberdashery', '14 Davis St', 'Market Hill', '1002', 'Helga Hoffman', '9334 0122', '9334 0123');

-- HireCompany Table
-- This table stores the details of the companies from which Local
-- Events hires their equipment

CREATE TABLE HireCompany
(companyID			VARCHAR2(6)		NOT NULL,
companyName			VARCHAR2(50)	NOT NULL,
streetAddress		VARCHAR2(50),
suburb			VARCHAR2(30),
postcode			CHAR(4),
contactName			VARCHAR2(50),
contactPhoneNo		VARCHAR2(15),
contactFaxNo		VARCHAR2(15),
PRIMARY KEY (companyID));

INSERT INTO HireCompany
VALUES
('HC0001', 'Herman''s Hiring', '28 Davis St', 'Market Hill', '1002', 'Herman Hoffman', '9334 7868', '9334 7869');

INSERT INTO HireCompany
VALUES
('HC0002', 'Tables and Chairs', '4 High St', 'Local Town', '1001', 'Terry Smith', '9333 9089', '9333 9088');

INSERT INTO HireCompany
VALUES
('HC0003', 'Con''s Communications', '20 High St', 'Local Town', '1001', 'Con Hatzis', '9333 5509', '9333 5508');

INSERT INTO HireCompany
VALUES
('HC0004', 'Function Fair', '2 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Janis Wigglesworth', '9335 9347', '9335 9348');

INSERT INTO HireCompany
VALUES
('HC0005', 'Eddie''s Electronics', '8 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Edward Peterson', '9335 7732', '9335 7731');

INSERT INTO HireCompany
VALUES
('HC0006', 'Light and Sound', '16 High St', 'Local Town', '1001', 'Benjamin King', '9333 2579', '9333 2599');

-- ServiceCompany Table
-- This table stores the details of the companies that Local Events
-- employs to provide catering and security for the events.

CREATE TABLE ServiceCompany
(companyID			VARCHAR2(6)		NOT NULL,
companyName			VARCHAR2(50)	NOT NULL,
streetAddress		VARCHAR2(50),
suburb			VARCHAR2(30),
postcode			CHAR(4),
contactName			VARCHAR2(50),
contactPhoneNo		VARCHAR2(15),
contactFaxNo		VARCHAR2(15),
typeOfService		CHAR(1) 	CHECK (typeOfService IN ('C', 'c', 'S', 's')), --catering or security
PRIMARY KEY (companyID));

INSERT INTO ServiceCompany
VALUES
('SC0001', 'Consumable Catering', '14 Market St', 'Market Hill', '1002', 'Jordan Baker', '9334 5555', '9334 5556', 'C');

INSERT INTO ServiceCompany
VALUES
('SC0002', 'Scrumptious Selections', '34 Market St', 'Market Hill', '1002', 'Antonio Biancotto', '9334 7777', '9334 7778', 'C');

INSERT INTO ServiceCompany
VALUES
('SC0003', 'Terrific Tucker', '83 Mahoney Rd', 'Fisherman''s Bend', '1003', 'Amy Peterson', '9335 8888', '9335 8889', 'C');

INSERT INTO ServiceCompany
VALUES
('SC0004', 'Function Security', '54 High St', 'Local Town', '1001', 'Mark Nichols', '9333 8888', '9333 8889', 'S');

INSERT INTO ServiceCompany
VALUES
('SC0005', 'Party Patrol', '36 Main Rd', 'Local Town', '1001', 'Gordon Hainsly', '9333 4444', '9333 4445', 'S');

-- Equipment Table
-- This table stores a list of equipment often required when setting up
-- an event.

CREATE TABLE Equipments
(equipmentCode			VARCHAR2(6)	NOT NULL,
equipmentDescription		VARCHAR2(100)	NOT NULL,
PRIMARY KEY (equipmentCode));

INSERT INTO Equipments
VALUES
('LEC001', 'Lectern');

INSERT INTO Equipments
VALUES
('TAB001', 'Circular Table Seats Eight');

INSERT INTO Equipments
VALUES
('TAB002', 'Circular Table Seats Twelve');

INSERT INTO Equipments
VALUES
('TAB003', 'Rectangular Table Seats Eight');

INSERT INTO Equipments
VALUES
('TAB004', 'Rectangular Table Seats Twelve');

INSERT INTO Equipments
VALUES
('CH0001', 'White Plastic Chair');

INSERT INTO Equipments
VALUES
('CH0002', 'Black Folding Chair');

INSERT INTO Equipments
VALUES
('OP0001', 'Overhead Projector');

INSERT INTO Equipments
VALUES
('NC0001', 'Notebook Computer');

INSERT INTO Equipments
VALUES
('WBP001', 'Printable White Board');

INSERT INTO Equipments
VALUES
('SP0001', 'Speaker');

INSERT INTO Equipments
VALUES
('MON001', 'Foldback Speaker');

INSERT INTO Equipments
VALUES
('AMP001', 'Amplifier');

INSERT INTO Equipments
VALUES
('MIC001', 'Dynamic Microphone');

INSERT INTO Equipments
VALUES
('MIC002', 'Wireless Microphone');

INSERT INTO Equipments
VALUES
('MIX001', 'Mixing Desk');

INSERT INTO Equipments
VALUES
('CDP001', 'CD Player');

INSERT INTO Equipments
VALUES
('DM0001', 'Display Monitor');

INSERT INTO Equipments
VALUES
('LI0001', 'Lights Par 16 50wt');

INSERT INTO Equipments
VALUES
('LI0002', 'Lights Par 56 300wt');

INSERT INTO Equipments
VALUES
('LI0003', 'Lights Multipar 600wt');

INSERT INTO Equipments
VALUES
('SM0004', 'Smoke Machine');

INSERT INTO Equipments
VALUES
('LS0005', 'Lighting Stand');

INSERT INTO Equipments
VALUES
('SL0006', 'Strobe Light');

INSERT INTO Equipments
VALUES
('DE0001', 'Digital Effects Unit');

-- Event Table
-- This table stores the event details

CREATE TABLE Events
(eventID			VARCHAR2(6)		NOT NULL,
eventName			VARCHAR2(50)	NOT NULL,
eventDescription		CLOB,
venueCapacityRequired	NUMBER(4)		NOT NULL,
cateringRequired		CHAR(1)		CHECK (cateringRequired IN ('N','n','Y','y')),
securityRequired		CHAR(1)		CHECK (securityRequired IN ('N','n','Y','y')),
typeOfEvent			VARCHAR2(30)	CHECK (typeOfEvent IN ('Meeting', 'Conference', 'Workshop', 'Function', 'Play', 'Concert')),
ticketPrice			NUMBER(6,2),
clientID			VARCHAR2(6)		NOT NULL,
PRIMARY KEY (eventID),
FOREIGN KEY (clientID) REFERENCES Clients(clientID));


INSERT INTO Events
VALUES
('E00001', 'Accountant''s Annual 2016', 'Local conference on latest trends in accounting', 150, 'Y', 'N', 'Conference', 150.00, 'C00011');

INSERT INTO Events
VALUES
('E00002', 'Bayman''s Bi-Annual Meeting', 'Company management meeting', 50, 'Y', 'N', 'Meeting', NULL, 'C00002');

INSERT INTO Events
VALUES
('E00003', 'Awards Night', 'Fisherman''s Bend Football Club''s Best and Fairest Awards', 300, 'Y', 'Y', 'Function', 75.00, 'C00010');

INSERT INTO Events
VALUES
('E00004', 'Awards Night', 'Athletics League Awards Evening', 250, 'Y', 'N', 'Function', 35.00, 'C00012');

INSERT INTO Events
VALUES
('E00005', 'Pearson''s Breakfast Meeting', NULL, 30, 'Y', 'N', 'Meeting', NULL, 'C00001');

INSERT INTO Events
VALUES
('E00006', 'Market Hill Council Christmas Function', NULL, 150, 'Y', 'Y', 'Function', 65.00, 'C00004');

INSERT INTO Events
VALUES
('E00007', 'Fisherman''s Bend Council Christmas Function', NULL, 300, 'Y', 'Y', 'Function', 75.00, 'C00005');

INSERT INTO Events
VALUES
('E00008', 'Football Fundraiser', 'Fisherman''s Bend Football Club''s Trivia Night Fundraiser', 500, 'Y', 'Y', 'Function', 75.00, 'C00010');

INSERT INTO Events
VALUES
('E00009', 'Local Town Council Christmas Function', NULL, 200, 'Y', 'Y', 'Function', 65.00, 'C00003');

INSERT INTO Events
VALUES
('E00010', 'High St Traders Christmas Function', NULL, 150, 'Y', 'N', 'Function', 45.00, 'C00001');

INSERT INTO Events
VALUES
('E00011', 'Accountant''s Annual 2017', 'Local conference on latest trends in accounting', 75, 'Y', 'N', 'Conference', 90.00, 'C00011');

INSERT INTO Events
VALUES
('E00012', 'Athletics Fundraiser', 'Local Town Athletics Dinner Dance', 400, 'Y', 'Y', 'Function', 70.00, 'C00012');

INSERT INTO Events
VALUES
('E00013', 'Macbeth', 'Local performers present Shakesperian Tragedy', 600, 'N', 'N', 'Play', 25.00, 'C00007');

INSERT INTO Events
VALUES
('E00014', 'Mimed Moments', 'Local performers present a night of quiet contemplation' , 600, 'N', 'N', 'Play', 20.00, 'C00006');

INSERT INTO Events
VALUES
('E00015', 'Bopping Ballet', 'Local ballet schools annual concert', 400, 'N', 'N', 'Concert', 15.00, 'C00008');

INSERT INTO Events
VALUES
('E00016', 'Tappin Tots', 'Song and Dance from the under fives', 200, 'N', 'N', 'Concert', 10.00, 'C00009');

INSERT INTO Events
VALUES
('E00017', 'The Wizard of Oz', 'The School of Song and Dance presents its 2017 production', 500, 'Y', 'N', 'Concert', 15.00, 'C00009');

INSERT INTO Events
VALUES
('E00018', 'Fame', 'The School of Song and Dance presents its 2018 production', 500, 'Y', 'N', 'Concert', 17.50, 'C00009');

INSERT INTO Events
VALUES
('E00019', 'Accountant''s Annual 2018', 'Local conference on latest trends in accounting', 75, 'Y', 'N', 'Conference', 100, 'C00011');

INSERT INTO Events
VALUES
('E00020', 'Romeo and Juliet', 'Local performers present Shakesperian Tragedy', 600, 'N', 'N', 'Play', 25.00, 'C00007');

INSERT INTO Events
VALUES
('E00021', 'A Comedy of Errors', 'Local performers present Shakesperian Comedy', 600, 'N', 'N', 'Play', 25.00, 'C00007');

INSERT INTO Events
VALUES
('E00022', 'Swing Band Night', 'Swingin'' Hits from the fifties and sixties', 150, 'N', 'N', 'Concert', 30.00, 'C00014');

INSERT INTO Events
VALUES
('E00023', 'Baroque Beauty', 'Presented by the Choral Society of Fisherman''s Bend', 100, 'N', 'N', 'Concert', 15.00, 'C00013');

INSERT INTO Events
VALUES
('E00024', 'Bee Keepers'' Annual Meeting', 'Fisherman''s Bend Bee Keeping Association Annual Meeting', 20, 'N', 'N', 'Meeting', NULL, 'C00015');

-- Ticket Table
-- This table stores the ticket information for each event

CREATE TABLE Tickets
(ticketNumber		NUMBER(4)		NOT NULL,
ticketDate		DATE			NOT NULL,
eventID			VARCHAR2(6)		NOT NULL,
promoterID		VARCHAR2(6),
PRIMARY KEY (ticketNumber, ticketDate, eventID),
FOREIGN KEY (eventID) REFERENCES Events(eventID),
FOREIGN KEY (promoterID) REFERENCES Promoters(promoterID));

--Stored procedure to assist inserting into Ticket table

CREATE OR REPLACE PROCEDURE InsertTicket(
startNumber		NUMBER,
numberOfTickets		NUMBER,
ticketDateTime		DATE,
eventNumber		Events.EventID%TYPE,
promoterNumber		Promoters.PromoterID%TYPE) AS
BEGIN
	FOR ticketNumber IN startNumber..numberOfTickets LOOP
		INSERT INTO Tickets
		VALUES
		(ticketNumber, ticketDateTime, eventNumber, promoterNumber);
	END LOOP;

END InsertTicket;
/

--Tickets sold for event E00001 - Accountants Annual 2016
--No Promoter
begin
  InsertTicket(1, 100, TO_DATE('12-JUN-2016 09:30', 'DD-MON-YYYY HH24:MI'), 'E00001', NULL);
end;
/
--EXECUTE InsertTicket(1, 100, TO_DATE('12-JUN-2016 09:30', 'DD-MON-YYYY HH24:MI'), 'E00001', NULL);

--Tickets sold for event E00003 - Fisherman's Bend Football Club's Best and Fairest Awards
--Promoted by P00005 - Coffee by the Lake

begin
  InsertTicket(1, 200, TO_DATE('29-SEP-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00003', 'P00005');
end;
/
--EXECUTE InsertTicket(1, 200, TO_DATE('29-SEP-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00003', 'P00005');

--Tickets sold for event E00004 - Athletics League Awards Evening
--Promoted by P00001 - Walter's Meats and P00002 - Clara's Cafe
begin
  InsertTicket(1, 120, TO_DATE('29-APR-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00004', 'P00001');
  InsertTicket(121, 200, TO_DATE('29-APR-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00004', 'P00002');
end;
/

--Tickets sold for event E00006 - Market Hill Council Christmas Function
--No Promoter
begin
  InsertTicket(1, 110, TO_DATE('09-DEC-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00006', NULL);
  InsertTicket(111, 145, TO_DATE('09-DEC-2016 19:30', 'DD-MON-YYYY HH24:MI'), 'E00006', NULL);
end;
/

--Tickets sold for event E00007 - Fisherman's Bend Council Christmas Function
--No Promoter
begin
  InsertTicket(1, 265, TO_DATE('01-DEC-2017 19:30', 'DD-MON-YYYY HH24:MI'), 'E00007', NULL);
end;
/
--Tickets sold for event E00008 - Football Fundraiser
--Promoter P00005 - Coffee by the lake, P00001 - Walter's Meats
begin
  InsertTicket(1, 175, TO_DATE('24-MAR-2017 19:30', 'DD-MON-YYYY HH24:MI'), 'E00008', 'P00005');
  InsertTicket(176, 320, TO_DATE('24-MAR-2017 19:30', 'DD-MON-YYYY HH24:MI'), 'E00008', 'P00001');
end;
/
--Tickets sold for event E00009 - Local Town Council Christmas Function
--Promoted by P00001 - Walter's Meats, P00002 - Clara's Cafe, P00003 - Tandoori Temptations, P00004 - Vietnamese Cuisine
begin
  InsertTicket(1, 50, TO_DATE('15-DEC-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00009', 'P00001');
  InsertTicket(51, 65, TO_DATE('15-DEC-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00009', 'P00002');
  InsertTicket(66, 140, TO_DATE('15-DEC-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00009', 'P00003');
  InsertTicket(141, 180, TO_DATE('15-DEC-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00009', 'P00004');
end;
/
--Tickets sold for event E00010 - High St Traders Christmas Function
begin
  InsertTicket(1, 120, TO_DATE('02-DEC-2017 13:00', 'DD-MON-YYYY HH24:MI'), 'E00010', 'P00001');
end;
/
--Tickets sold for event E00011 - Accountant's Annual 2017
begin
  InsertTicket(1, 70, TO_DATE('12-NOV-2017 09:00', 'DD-MON-YYYY HH24:MI'), 'E00011', NULL);
end;
/
--Tickets sold for event E00012 - Athletics Fundraiser
begin
  InsertTicket(1, 150, TO_DATE('14-JUL-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00012', 'P00002');
  InsertTicket(200, 340, TO_DATE('14-JUL-2017 19:00', 'DD-MON-YYYY HH24:MI'), 'E00012', 'P00003');
end;
/
--Tickets sold for event E00013 - Macbeth
begin
  InsertTicket(1, 150, TO_DATE('13-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00002');
  InsertTicket(1, 180, TO_DATE('14-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00002');
  InsertTicket(1, 200, TO_DATE('15-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00002');
  InsertTicket(300, 450, TO_DATE('13-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00004');
  InsertTicket(300, 520, TO_DATE('14-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00004');
  InsertTicket(300, 580, TO_DATE('15-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00013', 'P00004');
end;
/
--Tickets sold for event E00014 - Mimed Moments
begin
  InsertTicket(1, 130, TO_DATE('28-FEB-2018 20:00', 'DD-MON-YYYY HH24:MI'), 'E00014', 'P00002');
end;
/
--Tickets sold for event E00015 - Bopping Ballet
begin
  InsertTicket(1, 310, TO_DATE('14-JUN-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00015', 'P00002');
end;
/
--Tickets sold for event E00016 - Tappin' Tots
begin
  InsertTicket(1, 175, TO_DATE('22-JUN-2018 15:00', 'DD-MON-YYYY HH24:MI'), 'E00016', 'P00002');
end;
/
--Tickets sold for evecnt E00017 - The Wizard of Oz
begin
  InsertTicket(1, 350, TO_DATE('20-JUL-2017 19:30', 'DD-MON-YYYY HH24:MI'), 'E00017', 'P00003');
  InsertTicket(1, 420, TO_DATE('21-JUL-2017 19:30', 'DD-MON-YYYY HH24:MI'), 'E00017', 'P00003');
end;
/
--Tickets sold for event E00018 - Fame
begin
  InsertTicket(1, 200, TO_DATE('18-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00018', 'P00003');
  InsertTicket(1, 240, TO_DATE('19-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00018', 'P00004');
  InsertTicket(300, 450, TO_DATE('18-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00018', 'P00003');
  InsertTicket(300, 420, TO_DATE('19-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00018', 'P00004');
end;
/

--Tickets sold for event E00019 - Accountant Annual 2018
begin
  InsertTicket(1, 40, TO_DATE('10-NOV-2018 09:00', 'DD-MON-YYYY HH24:MI'), 'E00019', NULL);
end;
/
--Tickets sold for event E00020 - Romeo and Juliet
begin
  InsertTicket(1, 100, TO_DATE('25-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00020', 'P00002');
  InsertTicket(1, 150, TO_DATE('26-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00020', 'P00002');
  InsertTicket(300, 450, TO_DATE('25-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00020', 'P00004');
  InsertTicket(300, 520, TO_DATE('26-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'), 'E00020', 'P00004');
end;
/
--Tickets sold for event E00022 - Swing Band Night
begin
  InsertTicket(1, 55, TO_DATE('27-SEP-2018 20:30', 'DD-MON-YYYY HH24:MI'), 'E00022', 'P00001');
  InsertTicket(100, 120, TO_DATE('27-SEP-2018 20:30', 'DD-MON-YYYY HH24:MI'), 'E00022', 'P00002');
end;
/
--Tickets sold for event E00023 - Baroque Beauty
begin
  InsertTicket(1, 5, TO_DATE('16-NOV-2018 12:00', 'DD-MON-YYYY HH24:MI'), 'E00023', 'P00001');
end;
/
-- EventSponsor Table
-- This table provides the association between the events and their
-- sponsors

CREATE TABLE EventSponsors
(eventID			VARCHAR2(6)	NOT NULL,
businessID			VARCHAR2(6)	NOT NULL,
PRIMARY KEY (eventID, businessID),
FOREIGN KEY (eventID) REFERENCES Events(eventID),
FOREIGN KEY (businessID) REFERENCES Sponsors(businessID));


INSERT INTO EventSponsors
VALUES
('E00013', 'SP0001');

INSERT INTO EventSponsors
VALUES
('E00014', 'SP0003');

INSERT INTO EventSponsors
VALUES
('E00015', 'SP0003');

INSERT INTO EventSponsors
VALUES
('E00015', 'SP0005');

INSERT INTO EventSponsors
VALUES
('E00016', 'SP0005');

INSERT INTO EventSponsors
VALUES
('E00017', 'SP0001');

INSERT INTO EventSponsors
VALUES
('E00018', 'SP0002');

INSERT INTO EventSponsors
VALUES
('E00020', 'SP0001');

INSERT INTO EventSponsors
VALUES
('E00021', 'SP0001');

INSERT INTO EventSponsors
VALUES
('E00022', 'SP0004');

-- EventServices Table
-- This table provides information regarding which service companies
-- have been used for which events and at what charge.

CREATE TABLE EventServices
(eventID			VARCHAR2(6)	NOT NULL,
companyID			VARCHAR2(6)	NOT NULL,
eventCharge			NUMBER(8,2)	NOT NULL,
PRIMARY KEY (eventID, companyID),
FOREIGN KEY (eventID) REFERENCES Events(eventID),
FOREIGN KEY (companyID) REFERENCES ServiceCompany(companyID));

INSERT INTO EventServices
VALUES
('E00001', 'SC0002', 3000.00);

INSERT INTO EventServices
VALUES
('E00002', 'SC0001', 1500.00);

INSERT INTO EventServices
VALUES
('E00003', 'SC0003', 15000.00);

INSERT INTO EventServices
VALUES
('E00003', 'SC0004', 3500.00);

INSERT INTO EventServices
VALUES
('E00004', 'SC0001', 3750.00);

INSERT INTO EventServices
VALUES
('E00005', 'SC0001', 500.00);

INSERT INTO EventServices
VALUES
('E00006', 'SC0002', 7200.00);

INSERT INTO EventServices
VALUES
('E00006', 'SC0005', 1200.00);

INSERT INTO EventServices
VALUES
('E00007', 'SC0002', 18000.00);

INSERT INTO EventServices
VALUES
('E00007', 'SC0005', 2400.00);

INSERT INTO EventServices
VALUES
('E00008', 'SC0003', 12000.00);

INSERT INTO EventServices
VALUES
('E00008', 'SC0004', 3700.00);

INSERT INTO EventServices
VALUES
('E00009', 'SC0002', 10800.00);

INSERT INTO EventServices
VALUES
('E00009', 'SC0005', 1200.00);

INSERT INTO EventServices
VALUES
('E00010', 'SC0002', 4500.00);

INSERT INTO EventServices
VALUES
('E00011', 'SC0001', 3750.00);

INSERT INTO EventServices
VALUES
('E00012', 'SC0001', 8500.00);

INSERT INTO EventServices
VALUES
('E00012', 'SC0005', 2400.00);

-- EventEquipment Table
-- This table stores the equipment hired for each event, along with the
-- unit price and quantity.

CREATE TABLE EventEquipments
(eventID		VARCHAR2(6)	NOT NULL,
equipmentCode	VARCHAR2(6)	NOT NULL,
companyID		VARCHAR2(6)	NOT NULL,
unitPrice		NUMBER(6,2)	NOT NULL,
quantity		NUMBER(4)	NOT NULL,
noOfDays		NUMBER(3)	NOT NULL,
PRIMARY KEY (eventID, equipmentCode, companyID),
FOREIGN KEY (eventID) REFERENCES Events(eventID),
FOREIGN KEY (equipmentCode) REFERENCES Equipments(equipmentCode),
FOREIGN KEY (companyID) REFERENCES HireCompany(companyID));

INSERT INTO EventEquipments
VALUES
('E00001', 'LEC001', 'HC0001', 20.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00001', 'MIC002', 'HC0005', 130.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00001', 'SP0001', 'HC0005', 25.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00001', 'TAB004', 'HC0001', 12.00, 9, 1);

INSERT INTO EventEquipments
VALUES
('E00001', 'CH0002', 'HC0001', 3.00, 100, 1);

INSERT INTO EventEquipments
VALUES
('E00002', 'TAB003', 'HC0001', 8.00, 7, 1);

INSERT INTO EventEquipments
VALUES
('E00002', 'CH0002', 'HC0001', 3.00, 50, 1);

INSERT INTO EventEquipments
VALUES
('E00003', 'TAB001', 'HC0001', 8.00, 25, 1);

INSERT INTO EventEquipments
VALUES
('E00003', 'CH0001', 'HC0001', 2.00, 200, 1);

INSERT INTO EventEquipments
VALUES
('E00004', 'CH0001', 'HC0001', 2.00, 200, 1);

INSERT INTO EventEquipments
VALUES
('E00004', 'TAB001', 'HC0001', 8.00, 25, 1);

INSERT INTO EventEquipments
VALUES
('E00004', 'LEC001', 'HC0001', 20.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00004', 'MIC002', 'HC0005', 130.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00004', 'SP0001', 'HC0005', 25.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00006', 'TAB003', 'HC0001', 8.00, 19, 1);

INSERT INTO EventEquipments
VALUES
('E00006', 'CH0002', 'HC0001', 3.00, 145, 1);

INSERT INTO EventEquipments
VALUES
('E00007', 'TAB002', 'HC0002', 12.50, 23, 1);

INSERT INTO EventEquipments
VALUES
('E00007', 'CH0002', 'HC0002', 3.50, 265, 1);

INSERT INTO EventEquipments
VALUES
('E00008', 'TAB001', 'HC0001', 8.00, 40, 1);

INSERT INTO EventEquipments
VALUES
('E00008', 'CH0001', 'HC0001', 2.00, 320, 1);

INSERT INTO EventEquipments
VALUES
('E00008', 'OP0001', 'HC0003', 15.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00008', 'MIC001', 'HC0003', 11.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00008', 'AMP001', 'HC0003', 30.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00009', 'TAB003', 'HC0004', 8.50, 23, 1);

INSERT INTO EventEquipments
VALUES
('E00009', 'CH0001', 'HC0004', 2.20, 180, 1);

INSERT INTO EventEquipments
VALUES
('E00010', 'CH0001', 'HC0004', 2.20, 120, 1);

INSERT INTO EventEquipments
VALUES
('E00010', 'TAB003', 'HC0004', 8.50, 15, 1);

INSERT INTO EventEquipments
VALUES
('E00011', 'NC0001', 'HC0003', 25, 2, 1);

INSERT INTO EventEquipments
VALUES
('E00011', 'WBP001', 'HC0003', 20, 2, 1);

INSERT INTO EventEquipments
VALUES
('E00011', 'CH0002', 'HC0001', 3.00, 70, 1);

INSERT INTO EventEquipments
VALUES
('E00011', 'TAB003', 'HC0001', 8.00, 9, 1);

INSERT INTO EventEquipments
VALUES
('E00012', 'TAB002', 'HC0001', 12.00, 25, 1);

INSERT INTO EventEquipments
VALUES
('E00012', 'CH0001', 'HC0001', 2.00, 290, 1);

INSERT INTO EventEquipments
VALUES
('E00013', 'LS0005', 'HC0006', 50.00, 2, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'LI0001', 'HC0006', 50.00, 6, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'LI0002', 'HC0006', 75.00, 6, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'LI0003', 'HC0006', 125.00, 2, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'SM0004', 'HC0006', 30.00, 1, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'MON001', 'HC0006', 45.00, 3, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'MIC001', 'HC0006', 11.00, 3, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'DE0001', 'HC0006', 120.00, 1, 3);

INSERT INTO EventEquipments
VALUES
('E00013', 'MIX001', 'HC0006', 150.00, 1, 3);

INSERT INTO EventEquipments
VALUES
('E00014', 'LS0005', 'HC0006', 50.00, 2, 1);

INSERT INTO EventEquipments
VALUES
('E00014', 'LI0001', 'HC0006', 50.00, 4, 1);

INSERT INTO EventEquipments
VALUES
('E00014', 'LI0002', 'HC0006', 75.00, 4, 1);

INSERT INTO EventEquipments
VALUES
('E00014', 'LI0003', 'HC0006', 125.00, 2, 1);

INSERT INTO EventEquipments
VALUES
('E00014', 'SM0004', 'HC0006', 30.00, 1, 1);

INSERT INTO EventEquipments
VALUES
('E00014', 'SL0006', 'HC0006', 30.00, 2, 1);

INSERT INTO EventEquipments
VALUES
('E00016', 'CDP001', 'HC0003', 10.00, 2, 1);

-- EventVenue Table
-- This table records which venues are hired by particular events on
-- specific dates.

CREATE TABLE EventVenues
(eventID		VARCHAR2(6)		NOT NULL,
venueID			VARCHAR2(6)		NOT NULL,
bookingDate		DATE			NOT NULL,
PRIMARY KEY (eventID, venueID, bookingDate),
FOREIGN KEY (eventID) REFERENCES Events(eventID),
FOREIGN KEY (venueID) REFERENCES Venues(venueID));

INSERT INTO EventVenues
VALUES
('E00001', 'V00002', TO_DATE('12-JUN-2016 09:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00002', 'V00004', TO_DATE('14-AUG-2016 09:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00003', 'V00008', TO_DATE('29-SEP-2016 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00004', 'V00006', TO_DATE('29-APR-2016 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00005', 'V00010', TO_DATE('09-OCT-2016 08:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00006', 'V00006', TO_DATE('09-DEC-2016 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00007', 'V00009', TO_DATE('01-DEC-2017 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00008', 'V00008', TO_DATE('24-MAR-2017 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00009', 'V00006', TO_DATE('15-DEC-2017 19:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00010', 'V00002', TO_DATE('02-DEC-2017 13:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00011', 'V00004', TO_DATE('12-NOV-2017 09:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00012', 'V00001', TO_DATE('14-JUL-2017 19:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00013', 'V00003', TO_DATE('13-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00013', 'V00003', TO_DATE('14-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00013', 'V00003', TO_DATE('15-MAR-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00014', 'V00003', TO_DATE('06-JUN-2018 20:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00015', 'V00003', TO_DATE('14-JUN-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00016', 'V00006', TO_DATE('22-JUN-2018 15:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00017', 'V00003', TO_DATE('20-JUL-2017 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00017', 'V00003', TO_DATE('21-JUL-2017 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00018', 'V00003', TO_DATE('18-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00018', 'V00003', TO_DATE('19-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00019', 'V00004', TO_DATE('10-NOV-2018 09:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00020', 'V00003', TO_DATE('25-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00020', 'V00003', TO_DATE('26-JUL-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00021', 'V00003', TO_DATE('21-NOV-2018 19:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00022', 'V00009', TO_DATE('27-SEP-2018 20:30', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00023', 'V00007', TO_DATE('16-NOV-2018 12:00', 'DD-MON-YYYY HH24:MI'));

INSERT INTO EventVenues
VALUES
('E00024', 'V00007', TO_DATE('11-JAN-2018 20:00', 'DD-MON-YYYY HH24:MI'));

COMMIT;
