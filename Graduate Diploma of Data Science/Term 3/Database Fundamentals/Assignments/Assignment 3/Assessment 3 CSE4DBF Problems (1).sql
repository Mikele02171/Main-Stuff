--TASK 1
--TASK 1A. Display the name of the client who has made the most reservations with Getaway Holidays.

--My solution:
select C.NAME,COUNT(R.CLIENTNO) FROM CLIENT C,reservation R WHERE C.CLIENTNO = R.CLIENTNO AND R.STATUS <> 'Cancelled' GROUP BY C.NAME HAVING COUNT(R.CLIENTNO) = (SELECT MAX(COUNT(CLIENTNO)) FROM RESERVATION GROUP BY CLIENTNO);

--TASK 1B. Display the name of the client who has booked a reservation for the longest period.

--My Solution:
Select C.NAME as name From CLIENT C, RESERVATION R Where C.CLIENTNO = R.CLIENTNO AND R.ENDDATE-R.STARTDATE = (Select Max(ENDDATE-STARTDATE) From RESERVATION);

--TASK 1C. Display the room number, room type, room rate and number of guests for the reservation made by client(s) having last name ‘Perez’.
--My Solution:

Select C.NAME,RA.ROOMNO,ATY.ACCTYPENAME,ATY.ACCTYPERATE,R.NOOFGUESTS From RESERVATION_ACCOMMODATION RA,RESERVATION R, ACCOMMODATION A, ACCOMMODATION_TYPE ATY, CLIENT C
Where C.NAME like '%Perez'and C.CLIENTNO = R.CLIENTNO and R.RESNO = RA.RESNO and RA.ROOMNO = A.ROOMNO and A.ACCTYPEID = ATY.ACCTYPEID;


--TASK 1D. Display the name of the outdoor instructor who has the most duties as an activity supervisor.
SELECT OI.INSTRNAME,COUNT(*)
FROM OUTDOOR_INSTRUCTOR OI, ACTIVITY_SUPERVISOR ACTS, IFIELD INF, SUPERVISION SU
WHERE OI.INSTRUCTORID = INF.INSTRUCTORID AND OI.SUPERVISORID = SU.SUPERVISORID AND SU.SUPERVISORID = ACTS.SUPERVISORID 
GROUP BY OI.INSTRNAME  
HAVING COUNT(OI.INSTRUCTORID) = (SELECT MAX(COUNT(INSTRUCTORID)) FROM OUTDOOR_INSTRUCTOR GROUP BY INSTRUCTORID);

--My Solution:
SELECT OI.INSTRNAME
FROM OUTDOOR_INSTRUCTOR OI, SUPERVISION SU
WHERE  OI.SUPERVISORID = SU.SUPERVISORID
GROUP BY OI.INSTRNAME, OI.SUPERVISORID 
HAVING COUNT(SU.SUPERVISORID) = (SELECT MAX(COUNT(SUPERVISORID)) FROM SUPERVISION GROUP BY SUPERVISORID);

--TASK 1E. Display the reservations (reservation number and duration) whose duration is greater than the average duration of reservations.
--My Solution:
Select R.RESNO,R.ENDDATE-R.STARTDATE From RESERVATION R Where R.ENDDATE-R.STARTDATE > (SELECT AVG(ENDDATE-STARTDATE) FROM RESERVATION);

--HINT: in SQL, if you subtract two dates, what you get is a difference in days between those dates.

--TASK 2
--NOTE: Provide the implementation of the following stored procedures and function. For submission, please include both the PL/SQL code and an execute procedure / SQL statement to demonstrate the functionality.

--TASK 2A.
--Write a stored procedure that displays the contact details of clients who do not have any heart conditions or acrophobia. The resort wants to promote a new outdoor activity to them.
Create or Replace Procedure TEMP_CLIENT
As
    Cursor CLIENTDETAILS IS
        SELECT C.CLIENTNO,C.NAME,C.SEX,C.DOB,C.ADDRESS,C.PHONE,C.EMAIL,C.OCCUPATION,C.MARITALSTATUS,CC.CONDITION,A.ACTNAME
        FROM CLIENT C, CCONDITION CC, CLIENT_PREFERENCE CP, ACTIVITY A
        Where C.CLIENTNO = CC.CLIENTNO
        and C.CLIENTNO = CP.CLIENTNO
        and CP.ACTIVITYID = A.ACTIVITYID
        and CC.CONDITION <> 'Heart Condition'
        and CC.CONDITION <> 'Acrophobia';
  		
Begin
    FOR TV in CLIENTDETAILS Loop
        DBMS_OUTPUT.PUT_LINE(TV.CLIENTNO || ' | ' || TV.NAME|| ' | ' || TV.SEX || ' | ' || TV.DOB || ' | ' || TV.ADDRESS  || ' | ' || TV.PHONE || '|' || TV.EMAIL || '|' || TV.OCCUPATION || '|' || TV.MARITALSTATUS || '|' || TV.CONDITION );
        
    End Loop;   
	
End TEMP_CLIENT;
/
 
BEGIN
  TEMP_CLIENT;
END;


--TASK 2B.
--Write a stored function that uses the reservation number, activity ID and date as input and returns the name of the supervisor assigned for that specific activity.
Create or Replace Function SUPERVISOR(P_ResNo SUPERVISION.RESNO%TYPE, P_Actid SUPERVISION.ACTIVITYID%TYPE, P_Timedate SUPERVISION.DAY%TYPE)
RETURN VARCHAR2 IS
	V_SUPERVISORID VARCHAR2(20);

Begin
	
	Select SUPERVISORID
	into V_SUPERVISORID
	From SUPERVISION 
    where RESNO = P_ResNo
    and ACTIVITYID = P_Actid
    and DAY = P_Timedate;

    IF V_SUPERVISORID = '1' THEN 
      RETURN 'Aaron Spencer Air Balloon Flying';
    ELSIF V_SUPERVISORID = '2' THEN
      RETURN 'Jony Abbott Rafting and Fishing';
    ELSIF V_SUPERVISORID = '3' THEN 
      RETURN 'Adam Addison Mountaineering and Bunjee Jumping';
    ELSIF V_SUPERVISORID = '4' THEN
      RETURN 'Albert Whitecker Fishing';
    ELSIF V_SUPERVISORID = '5' THEN
      RETURN 'Ray Hanley Outdoor Instructor';
    ELSIF V_SUPERVISORID = '6' THEN
      RETURN 'Abby Galler MASSEUSE Thai massage';
    ELSIF V_SUPERVISORID = '7' THEN
      RETURN 'Takisha Green MASSEUSE Spa treatment';
    ELSIF V_SUPERVISORID = '8' THEN
      RETURN 'Zahra Sheikh MASSEUSE Spa treatment';
    ELSIF V_SUPERVISORID = '9' THEN
      RETURN 'Oliver Austin Swimming';
    ELSIF V_SUPERVISORID = '10' THEN
      RETURN 'Joseph Tribiani Swimming';
    ELSIF V_SUPERVISORID = '11' THEN
      RETURN 'Ray Write OUTDOOR_INSTRUCTOR';
    ELSIF V_SUPERVISORID = '12' THEN
      RETURN 'Anthony De Silva OUTDOOR_INSTRUCTOR' ;
    ELSIF V_SUPERVISORID = '13' THEN
      RETURN 'Ehsan Bell OUTDOOR_INSTRUCTOR';
    ELSIF V_SUPERVISORID = '14' THEN
      RETURN 'Fransis Barnard OUTDOOR_INSTRUCTOR';
    ELSIF V_SUPERVISORID = '15' THEN
      RETURN 'Habib Zahid MASSEUSE Spa treatment';
    ELSIF V_SUPERVISORID = '16' THEN
      RETURN 'Tanira Musa MASSEUSE Thai massage';
    ELSE 
      RETURN 'Not Supervising';
    END IF;
    
			
End SUPERVISOR;
/

Select SUPERVISORID, SUPERVISOR(RESNO,ACTIVITYID,DAY) FROM SUPERVISION;


--TASK 3
--Provide the implementation of the following trigger. For submission, please include both the PL/SQL code and an insert statement to demonstrate the trigger functionality.


--A trigger that automatically raises an error whenever a client with aquaphobia selects rafting as a preferred outdoor activity.

CREATE OR REPLACE TRIGGER update_client
BEFORE INSERT ON CLIENT_PREFERENCE
FOR EACH ROW
DECLARE 
       CLIENTNO VARCHAR2(10);
       ACTIVITYID VARCHAR2(10);
BEGIN 
  
  SELECT * INTO CLIENTNO,ACTIVITYID FROM CLIENT_PREFERENCE;
  IF CLIENTNO = '2' AND ACTIVITYID = '4' THEN 
     RAISE_APPLICATION_ERROR(-20000,'This client can not choose rafting');
  END IF;
  IF CLIENTNO = '11' AND ACTIVITYID = '4' THEN 
     RAISE_APPLICATION_ERROR(-20000,'This client can not choose rafting');
  END IF;
  IF CLIENTNO = '15' AND ACTIVITYID = '4' THEN 
     RAISE_APPLICATION_ERROR(-20000,'This client can not choose rafting');
  END IF;
END update_client;
/

