<!---
FILENAME :
DESCRIPTION : train / live mode db names

INPUT : Session.vars.locid

OUTPUT : DB_NAMES

USAGE :

Include File :
<cfmodule template="#request.apppath#Claims/CustomTags\MICSyncDB.cfm">


CREATED BY : LISA YII
CREATED ON : March 2016

Port over from MInsCore

REVISION HISTORY

BY          ON          REMARKS
=========   ==========  ======================================================================================
--->

<cfparam name="livemode" default="1">
<CFIF StructKeyExists(URL,"train")>
	<cfset livemode = 0>
</CFIF>

<cfset DB_NAMES=StructNew()>

<cfset DB_NAMES.SOURCE_TITLE="">
<cfset DB_NAMES.TARGET_TITLE="">
<cfset DB_NAMES.SOURCE_DB="">
<cfset DB_NAMES.TARGET_DB="">
<cfset DB_NAMES.SOURCE_DBCF="">
<cfset DB_NAMES.TARGET_DBCF="">
<CFSET DB_NAMES.SYNC = 0>

<CFIF livemode eq 1><!--- live --->
	<CFSET DB_NAMES.SOURCE_TITLE="Live">
	<CFSET DB_NAMES.TARGET_TITLE="Training">
<CFELSE>
	<CFSET DB_NAMES.SOURCE_TITLE="Training">
	<CFSET DB_NAMES.TARGET_TITLE="Live">
</CFIF>

<CFIF Application.appdevmode eq 1>
	<cfset str="CLAIMS_DEV,">
<cfelse>
	<cfset str="">
</CFIF>

<CFIF listfindnocase("#str#",REQUEST.MTRDSN) gt 0 OR application.db_mode eq "PROD" or application.db_mode eq "TRAIN">
	<CFSET DB_NAMES.SYNC = 1>
		<cfswitch expression="#application.applocid#">
			<cfcase value="1"><!--- Malaysia --->
				<CFIF livemode eq 1><!--- live --->
					<CFIF Application.appdevmode eq 1>
						<CFSET DB_NAMES.SOURCE_DB="claims_dev">
						<CFSET DB_NAMES.SOURCE_DBCF="claims_dev">
						<CFSET DB_NAMES.TARGET_DB="claims_dev_dummy">
						<CFSET DB_NAMES.TARGET_DBCF="claims_dev_dummy">
					<cfelse>
						<CFSET DB_NAMES.SOURCE_DB="mymotor_prod2">
						<CFSET DB_NAMES.SOURCE_DBCF="mymotor_prod2">
						<CFSET DB_NAMES.TARGET_DB="mymotor_train">
						<CFSET DB_NAMES.TARGET_DBCF="mymotor_train">
					</cfif>
				<CFELSE>
					<CFSET DB_NAMES.SOURCE_DB="mymotor_train">
					<CFSET DB_NAMES.SOURCE_DBCF="mymotor_train">
					<CFSET DB_NAMES.TARGET_DB="mymotor_prod2">
					<CFSET DB_NAMES.TARGET_DBCF="mymotor_prod2">
				</CFIF>
			</cfcase>
			<cfcase value="2"><!--- Singapore --->
				<CFIF livemode eq 1><!--- live --->
					<CFSET DB_NAMES.SOURCE_DB="sg_motor_PROD">
					<CFSET DB_NAMES.SOURCE_DBCF="sg_motor_PROD">
					<CFSET DB_NAMES.TARGET_DB="sg_motor_TRAIN">
					<CFSET DB_NAMES.TARGET_DBCF="sg_motor_TRAIN">
				<CFELSE>
					<CFSET DB_NAMES.SOURCE_DB="sg_motor_TRAIN">
					<CFSET DB_NAMES.SOURCE_DBCF="sg_motor_TRAIN">
					<CFSET DB_NAMES.TARGET_DB="sg_motor_PROD">
					<CFSET DB_NAMES.TARGET_DBCF="sg_motor_PROD">
				</CFIF>
			</cfcase>
			<cfcase value="7"><!--- Indonesia --->
				<CFIF livemode eq 1><!--- live --->
					<CFSET DB_NAMES.SOURCE_DB="INDO_PRODUCTION">
					<CFSET DB_NAMES.SOURCE_DBCF="INDO_PRODUCTION">
					<CFSET DB_NAMES.TARGET_DB="INDO_TRAINING">
					<CFSET DB_NAMES.TARGET_DBCF="INDO_TRAINING">
				<CFELSE>
					<CFSET DB_NAMES.SOURCE_DB="INDO_TRAINING">
					<CFSET DB_NAMES.SOURCE_DBCF="INDO_TRAINING">
					<CFSET DB_NAMES.TARGET_DB="INDO_PRODUCTION">
					<CFSET DB_NAMES.TARGET_DBCF="INDO_PRODUCTION">
				</CFIF>
			</cfcase>
			<cfcase value="11"><!--- Thailand --->
				<CFIF livemode eq 1><!--- live --->
					<CFSET DB_NAMES.SOURCE_DB="TH_CLAIMS_PROD">
					<CFSET DB_NAMES.SOURCE_DBCF="TH_CLAIMS_PROD">
					<CFSET DB_NAMES.TARGET_DB="TH_CLAIMS_TRAIN">
					<CFSET DB_NAMES.TARGET_DBCF="TH_CLAIMS_TRAIN">
				<CFELSE>
					<CFSET DB_NAMES.SOURCE_DB="TH_CLAIMS_TRAIN">
					<CFSET DB_NAMES.SOURCE_DBCF="TH_CLAIMS_TRAIN">
					<CFSET DB_NAMES.TARGET_DB="TH_CLAIMS_PROD">
					<CFSET DB_NAMES.TARGET_DBCF="TH_CLAIMS_PROD">
				</CFIF>
			</cfcase>

			<cfcase value="15"><!--- Vietnam --->
				<CFIF livemode eq 1><!--- live --->
					<CFSET DB_NAMES.SOURCE_DB="VN_CLAIMS_PROD">
					<CFSET DB_NAMES.SOURCE_DBCF="VN_CLAIMS_PROD">
					<CFSET DB_NAMES.TARGET_DB="VN_CLAIMS_TRAIN">
					<CFSET DB_NAMES.TARGET_DBCF="VN_CLAIMS_TRAIN">
				<CFELSE>
					<CFSET DB_NAMES.SOURCE_DB="VN_CLAIMS_TRAIN">
					<CFSET DB_NAMES.SOURCE_DBCF="VN_CLAIMS_TRAIN">
					<CFSET DB_NAMES.TARGET_DB="VN_CLAIMS_PROD">
					<CFSET DB_NAMES.TARGET_DBCF="VN_CLAIMS_PROD">
				</CFIF>
			</cfcase>
		</cfswitch>
</cfif>