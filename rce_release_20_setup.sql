DROP TABLE IF EXISTS user_login_encrypt;
DROP TABLE IF EXISTS user_session_group_users;
DROP TABLE IF EXISTS user_session_group_invites;
DROP TABLE IF EXISTS user_session_groups;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS user_session_tracking;
DROP TABLE IF EXISTS user_logins;
DROP TABLE IF EXISTS mobile_services;
DROP TABLE IF EXISTS error_logs;
DROP TABLE IF EXISTS bgmrpgm_down_files;
DROP TABLE IF EXISTS bgmrpgm_down_game_versions;
DROP TABLE IF EXISTS bgmrpgm_down_games;
DROP PROCEDURE IF EXISTS user_create_update_proc;
DROP PROCEDURE IF EXISTS user_session_log_proc;
DROP PROCEDURE IF EXISTS user_session_group_create_proc;
DROP PROCEDURE IF EXISTS user_session_group_invite_proc;
DROP PROCEDURE IF EXISTS user_session_group_invite_finish_proc;
DROP PROCEDURE IF EXISTS user_session_group_check_proc;
DROP PROCEDURE IF EXISTS get_mobile_services_proc;
DROP PROCEDURE IF EXISTS msg_send_proc;
DROP PROCEDURE IF EXISTS msg_send_two_param_proc;
DROP PROCEDURE IF EXISTS msg_send_three_param_proc;
DROP PROCEDURE IF EXISTS bgmrpgm_down_reg_proc;
DROP PROCEDURE IF EXISTS bgmrpgm_down_info_proc; 
DROP PROCEDURE IF EXISTS bgmrpgm_down_vers_proc;
DROP PROCEDURE IF EXISTS store_error_proc;
DROP PROCEDURE IF EXISTS log_error_proc;

SET NAMES 'utf8';
SET CHARACTER SET utf8;

CREATE TABLE mobile_services (

	mobile_service_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	mobile_service_name VARCHAR(25) NOT NULL,
	service_url VARCHAR(25) NOT NULL
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_logins (

	user_login_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_name VARCHAR(25) NOT NULL,
	password BINARY(32) NOT NULL,
	phone_number BINARY(64),
	email BINARY(64),
	mobile_service_id INT(10) UNSIGNED,
	CONSTRAINT fk_user_logins_mobile_service_id FOREIGN KEY (mobile_service_id) REFERENCES mobile_services (mobile_service_id),
    CONSTRAINT uk_user_logins_user_name UNIQUE KEY (user_name)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_sessions (

	user_session_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	client_id INT(12) UNSIGNED NOT NULL,
	user_login_id INT(10) UNSIGNED,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_sessions_user_login_id UNIQUE KEY (user_login_id),
	CONSTRAINT fk_user_sessions_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id),
    INDEX ix_user_sessions_client_id (client_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_session_tracking (

	user_session_tracking_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	client_id INT(12) UNSIGNED NOT NULL,
	user_login_id INT(10) UNSIGNED,
	date_session_created DATETIME NOT NULL,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_user_session_tracking_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_login_encrypt (

	user_login_encrypt_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	encrypt_key BINARY(16) NOT NULL,
	user_login_id INT(10) UNSIGNED,
	CONSTRAINT fk_user_login_encrypt_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id),
    CONSTRAINT uk_user_login_encrypt_user_login_id UNIQUE KEY (user_login_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_session_groups (

	user_session_group_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	group_id VARCHAR(36) NOT NULL,
	user_login_id INT(10) UNSIGNED,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_session_groups_user_login_id UNIQUE KEY (user_login_id),
	CONSTRAINT fk_user_session_groups_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id),
    INDEX ix_user_session_groups_group_id (group_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_session_group_invites (

	user_session_group_invite_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_session_group_id INT(12) UNSIGNED NOT NULL,
	user_login_id INT(10) UNSIGNED NOT NULL,
	date_expired DATETIME NOT NULL,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_session_group_invites_user_login_id UNIQUE KEY (user_login_id),
	CONSTRAINT fk_user_session_group_invites_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id),
	CONSTRAINT fk_user_session_group_invites_user_session_group_id FOREIGN KEY (user_session_group_id) REFERENCES user_session_groups (user_session_group_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_session_group_users (

	user_session_group_user_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_session_group_id INT(12) UNSIGNED NOT NULL,
	user_login_id INT(10) UNSIGNED NOT NULL,
    CONSTRAINT uk_user_session_group_users_user_login_id UNIQUE KEY (user_login_id),
	CONSTRAINT fk_user_session_group_users_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_logins (user_login_id),
	CONSTRAINT fk_user_session_group_users_user_session_group_id FOREIGN KEY (user_session_group_id) REFERENCES user_session_groups (user_session_group_id)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE error_logs (

	error_log_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,	
	user_login_id INT(10) UNSIGNED,
	user_name VARCHAR(25),
	client_id INT(12) UNSIGNED,
	error_num INT,
	error_text TEXT, 
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bgmrpgm_down_games (

	bgmrpgm_down_game_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	bgmrpgm_down_game_name VARCHAR(25) NOT NULL,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_bgmrpgm_down_game_name UNIQUE KEY (bgmrpgm_down_game_name)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bgmrpgm_down_game_versions (

	bgmrpgm_down_game_version_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	bgmrpgm_down_game_version_number DECIMAL(10, 5) DEFAULT 0.0,
	bgmrpgm_down_game_id INT(10) UNSIGNED NOT NULL,
	date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_bgmrpgm_down_game_versions_game_id FOREIGN KEY (bgmrpgm_down_game_id) REFERENCES bgmrpgm_down_games (bgmrpgm_down_game_id),
    CONSTRAINT uk_bgmrpgm_down_game_versions_specification UNIQUE KEY (bgmrpgm_down_game_id, bgmrpgm_down_game_version_number)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bgmrpgm_down_files (

	bgmrpgm_down_file_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	bgmrpgm_down_file_designation VARCHAR(25) NOT NULL,
	bgmrpgm_down_file_type VARCHAR(25) NOT NULL,
	bgmrpgm_down_file_path TEXT NOT NULL,
	bgmrpgm_down_game_version_id INT(10) UNSIGNED NOT NULL,
	CONSTRAINT fk_bgmrpgm_down_files_game_version_id FOREIGN KEY (bgmrpgm_down_game_version_id) REFERENCES bgmrpgm_down_game_versions (bgmrpgm_down_game_version_id),
	CONSTRAINT uk_bgmrpgm_down_files_designations UNIQUE KEY (bgmrpgm_down_file_designation)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELIMITER //

CREATE PROCEDURE user_create_update_proc(strUserName VARCHAR(25), 
										 strPassword VARCHAR(16), 
										 strPhoneNum VARCHAR(16), 
									     strEmail VARCHAR(25), 
										 strMobServID VARCHAR(25), 
										 boolIsUpdate BOOL, 
										 nClientID INT(12),
										 nTransID INT(10), 
										 nRespID INT(10)) 
BEGIN
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE strResult VARCHAR(50) DEFAULT 'User created.';

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(NULL, strUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_create_update_proc - ', txErrorMsg));
       
		 CALL msg_send_two_param_proc(nTransID, 
									  nRespID, 
									  nClientID,
									  'USERCREATE',
									  'RCECORE',
									  'UserCreateStatus',
									  'false',
									  'Error occurred.');
    END;

	SELECT user_login_id
	FROM user_logins 
	WHERE user_name = strUserName
	INTO nUserLoginID;

	IF (nUserLoginID > 0 AND boolIsUpdate = TRUE) OR 
	   (nUserLoginID <= 0 AND boolIsUpdate = FALSE)
	THEN
	
	    IF boolIsUpdate = FALSE
	    THEN
	    
			INSERT INTO user_logins (user_name, password)
			VALUES (strUserName, UNHEX(SHA2(strPassword, 0)));
	
			SET nUserLoginID = LAST_INSERT_ID();
		ELSE
	    
			UPDATE user_logins 
			SET password = UNHEX(SHA2(strPassword, 0))
			WHERE user_login_id = nUserLoginID;
		
			DELETE FROM user_login_encrypt
			WHERE user_login_id = nUserLoginID;
		END IF;
	
		INSERT INTO user_login_encrypt (encrypt_key, user_login_id)
        VALUES (UNHEX(REPLACE(UUID(), '-', '')), nUserLoginID);
    	
        IF strPhoneNum <> 'NULL' AND strPhoneNum IS NOT NULL AND strPhoneNum <> '' AND
           strMobServID <> 'NULL' AND strMobServID <> '0' AND 
           strMobServID IS NOT NULL AND strMobServID <> ''
        THEN 
    
	        UPDATE user_logins
	   		INNER JOIN user_login_encrypt ON user_logins.user_login_id = nUserLoginID
	                                	 AND user_login_encrypt.user_login_id = nUserLoginID
	   		SET user_logins.phone_number = AES_ENCRYPT(strPhoneNum, HEX(user_login_encrypt.encrypt_key)),
	   			user_logins.mobile_service_id = CAST(strMobServID AS UNSIGNED);
        ELSE
     
	        UPDATE user_logins
	   		SET phone_number = NULL,
	   		    mobile_service_id = NULL
	   		WHERE user_login_id = nUserLoginID;
	   	
        END IF;
       
        IF strEmail <> 'NULL' AND strEmail IS NOT NULL AND strEmail <> '' 
        THEN 
     
	        UPDATE user_logins
	   		INNER JOIN user_login_encrypt ON user_logins.user_login_id = nUserLoginID
	                                	 AND user_login_encrypt.user_login_id = nUserLoginID
	   		SET user_logins.email = AES_ENCRYPT(strEmail, HEX(user_login_encrypt.encrypt_key));
        ELSE
     
	        UPDATE user_logins
	   		SET email = NULL
	   		WHERE user_login_id = nUserLoginID;
        END IF;
       
        IF boolIsUpdate = TRUE
        THEN
        
        	SET strResult = 'User updated.';
        END IF;

		CALL msg_send_two_param_proc(nTransID, 
									 nRespID, 
									 nClientID,
									 'USERCREATE',
									 'RCECORE',
									 'UserCreateStatus',
									 'true',
									 strResult);
	ELSE
	
		IF nUserLoginID > 0
		THEN
	
			SET strResult = 'Username already exists.';
		ELSE
	
			SET strResult = 'Username not found for update.';
		END IF;
	
		CALL msg_send_two_param_proc(nTransID, 
									 nRespID, 
									 nClientID,
									 'USERCREATE',
									 'RCECORE',
									 'UserCreateStatus',
									 'false',
									 strResult);
	END IF;
END //

CREATE PROCEDURE user_session_log_proc(strSendUserName VARCHAR(25), 
								       strPassword VARCHAR(16), 
									   nClientID INT(12),
									   nTransID INT(10), 
									   nRespID INT(10)) 
BEGIN
	DECLARE nUserSessionID INT(10) DEFAULT 0;
	DECLARE nSessionClientID INT(12) DEFAULT 0;
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE dtCreated DATETIME DEFAULT NULL;
	DECLARE strUserName VARCHAR(25) DEFAULT ''; 
	DECLARE strMsgName VARCHAR(25) DEFAULT 'login_confirmed';
	DECLARE strLoginConfirm VARCHAR(50) DEFAULT 'true';
	DECLARE strLoginMsg VARCHAR(50) DEFAULT 'Login successful.';

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(nUserLoginID, strUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_session_log_proc - ', txErrorMsg));
    END;
	
	SELECT user_login_id
	FROM user_logins 
	WHERE user_name = strSendUserName
	  AND HEX(password) = SHA2(strPassword, 0)
	INTO nUserLoginID;

	IF nUserLoginID > 0
	THEN
	
		SET strUserName = strSendUserName;
		
		SELECT user_session_id,
			   client_id,
			   date_created
		FROM user_sessions 
		WHERE user_login_id = nUserLoginID
		INTO nUserSessionID,
			 nSessionClientID,
			 dtCreated;

		IF nSessionClientID > 0 AND nSessionClientID != nClientID
		THEN
		
			DELETE FROM user_session_group_users
			WHERE user_login_id = nUserLoginID;
		
			DELETE FROM user_session_group_invites
			WHERE user_login_id = nUserLoginID;
		
			DELETE FROM user_session_groups
			WHERE user_login_id = nUserLoginID;
		
			DELETE FROM user_sessions
			WHERE user_session_id = nUserSessionID;
		
			INSERT INTO user_session_tracking (client_id, user_login_id, date_session_created)
			VALUES (nSessionClientID, nUserLoginID, dtCreated);
	
			INSERT INTO user_sessions (client_id, user_login_id)
			VALUES (nClientID, nUserLoginID);
		ELSEIF nSessionClientID <= 0
		THEN
		
			INSERT INTO user_sessions (client_id, user_login_id)
			VALUES (nClientID, nUserLoginID);
		ELSE
		
			SET strLoginMsg = 'User already logged in.';
		END IF;
	
	ELSE
				
		SET strMsgName = 'login_failed';
		SET strLoginConfirm = 'false';
		SET strLoginMsg = 'User name or password was invalid.';
	END IF;

	CALL msg_send_three_param_proc(nTransID, 
								   nRespID, 
								   nClientID,
								   strMsgName,
								   'RCECORE',
								   'LoginConfirm',
							  	   strLoginConfirm,
							  	   strUserName,
								   strLoginMsg);
END //

CREATE PROCEDURE user_session_group_create_proc(strSendUserName VARCHAR(25), 
										   		strGroupID VARCHAR(36),
										  		nClientID INT(12),
										   		nTransID INT(10), 
										   		nRespID INT(10)) 
BEGIN
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE nSessionGroupID INT(12) DEFAULT 0;
	DECLARE strCurrentGroupID VARCHAR(36) DEFAULT '';
	DECLARE strMsgName VARCHAR(25) DEFAULT 'group_create_confirmed';
	DECLARE strCreateConfirm VARCHAR(50) DEFAULT 'true';
	DECLARE strCreateMsg VARCHAR(50) DEFAULT 'Session group successful.';

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(nUserLoginID, strSendUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_session_group_create_proc - ', txErrorMsg));
    END;
	
	SELECT user_login_id
	FROM user_logins 
	WHERE user_name = strSendUserName
	INTO nUserLoginID;

	IF nUserLoginID > 0
	THEN
		
		SELECT user_session_group_id,
			   group_id
		FROM user_session_groups 
		WHERE user_login_id = nUserLoginID
		INTO nSessionGroupID,
			 strCurrentGroupID;
			
		IF nSessionGroupID > 0 AND 
		   strCurrentGroupID != '' AND 
		   strCurrentGroupID != strGroupID
		THEN
		
			DELETE FROM user_session_group_users
			WHERE user_login_id = nUserLoginID;

			DELETE FROM user_session_group_invites
			WHERE user_login_id = nUserLoginID;
		
			DELETE FROM user_session_groups 
			WHERE user_login_id = nUserLoginID;
		
			SET nSessionGroupID = 0;
		
		END IF;

		IF nSessionGroupID <= 0
		THEN
		
			CALL RevComm_StartGroup(nClientID, strGroupID);
		
			SET strCreateMsg = 'Session group created or already exists.';
		ELSE
		
			SET strCreateMsg = 'Already in session group.';
		END IF;
	
	ELSE
				
		SET strMsgName = 'group_create_failed';
		SET strCreateConfirm = 'false';
		SET strCreateMsg = 'User name was invalid.';
	END IF;

	CALL msg_send_two_param_proc(nTransID, 
								 nRespID, 
								 nClientID,
								 strMsgName,
								 'RCECORE',
								 'SessionGroupCreateConfirm',
							  	 strCreateConfirm,
							  	 strCreateMsg);
END //

CREATE PROCEDURE user_session_group_invite_proc(strSendUserName VARCHAR(25), 
										   		strInviteUserName VARCHAR(25), 
										  		nSetLimitInSecs INT,
										  		strGroupID VARCHAR(36),
										   		nClientID INT(12),
										   		nTransID INT(10), 
										   		nRespID INT(10)) 
BEGIN
	DECLARE nLimitInSecs INT DEFAULT 30;
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE nInviteLoginID INT(10) DEFAULT 0;
	DECLARE nInviteClientID INT(12) DEFAULT 0;
	DECLARE nSessionGroupID INT(12) DEFAULT 0;
	DECLARE strServerGroupID VARCHAR(36) DEFAULT '';
	DECLARE nInviteSessionGroupID INT(12) DEFAULT 0;
	DECLARE dtInviteExpired DATETIME DEFAULT NULL;
	DECLARE strMsgName VARCHAR(25) DEFAULT 'group_invite_confirmed';
	DECLARE strInviteConfirm VARCHAR(50) DEFAULT 'true';
	DECLARE strInviteMsg VARCHAR(50) DEFAULT 'Session group invite successful.';
	DECLARE nInviteMsgGroupID INT(10);
	DECLARE nInviteMsgID INT(10);
	DECLARE nSelectedID INT(10);
	DECLARE strInviteUserMsg MEDIUMBLOB;

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(nUserLoginID, strSendUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_session_group_invite_proc - ', txErrorMsg));
   END;
  
   IF strSendUserName != strInviteUserName
   THEN
   
	   IF nSetLimitInSecs IS NOT NULL AND nSetLimitInSecs > 0
	   THEN
	   
	   		SET nLimitInSecs = nSetLimitInSecs;
	   END IF;
		
		SELECT user_login_id
		FROM user_logins 
		WHERE user_name = strSendUserName
		INTO nUserLoginID;
		
		SELECT ul.user_login_id,
			   us.client_id,
			   IFNULL(usgs.user_session_group_user_id, 0)
		FROM user_logins ul INNER JOIN user_sessions us ON us.user_login_id = ul.user_login_id
							LEFT JOIN user_session_group_users usgs ON usgs.user_login_id = ul.user_login_id
		WHERE ul.user_name = strInviteUserName
		INTO nInviteLoginID,
			 nInviteClientID,
			 nInviteSessionGroupID;
	
		IF strGroupID IS NOT NULL AND strGroupID != ''
		THEN
		
			IF nUserLoginID > 0 AND nInviteLoginID > 0
			THEN
				
				SELECT user_session_group_id,
					   group_id
				FROM user_session_groups 
				WHERE user_login_id = nUserLoginID
				INTO nSessionGroupID,
					 strServerGroupID;
	
				DELETE FROM user_session_group_invites
				WHERE user_login_id = nInviteLoginID
				  AND date_expired <= NOW();
			
				IF nSessionGroupID <= 0
				THEN
		
					INSERT INTO user_session_groups (user_login_id, group_id)
					VALUES (nUserLoginID, strGroupID);
				
					SET nSessionGroupID = LAST_INSERT_ID();
					SET strServerGroupID = strGroupID;
				
					INSERT INTO user_session_group_users (user_login_id, user_session_group_id)
					VALUES (nUserLoginID, nSessionGroupID);
				END IF;
		
				IF nSessionGroupID > 0 AND nInviteSessionGroupID <= 0
				THEN
				
					IF strServerGroupID = strGroupID
					THEN
					
						IF nInviteClientID > 0
						THEN
						
							INSERT INTO user_session_group_invites (user_session_group_id, user_login_id, date_expired)
							VALUES (nSessionGroupID, nInviteLoginID, DATE_ADD(NOW(), INTERVAL nLimitInSecs second));
						
							CALL RevComm_JSONMsgGroupCreate(CONCAT('nvite', CAST(nUserLoginID AS CHAR), CAST(nInviteLoginID AS CHAR)),
															nInviteMsgGroupID);
							CALL RevComm_JSONMsgCreate(nInviteMsgGroupID, 
													   'RCECORE', 
													   nInviteMsgID);
							CALL RevComm_JSONMsgJSFuncCall(nInviteMsgID, 
													  	   'SessionGroupInviteReceive', 
													  	   CONCAT('"', strSendUserName, ' has sent an invite."'), 
													  	   FALSE, 
													  	   nSelectedID);
							CALL RevComm_JSONMsgJSFuncAddParam(nSelectedID, 
													  	   	   CONCAT('"', strSendUserName, '"'), 
													  	   	   1,
													  	       FALSE);
							CALL RevComm_JSONMsgSaveClose(nInviteMsgID);
							CALL RevComm_JSONMsgsOutput(nInviteMsgGroupID, strInviteUserMsg);
							
							CALL RevComm_SendMsgUser(nInviteClientID, strInviteUserMsg);
						ELSE
							
							SET strMsgName = 'group_invite_failed';
							SET strInviteConfirm = 'false';
							SET strInviteMsg = 'Error: Invited user session not found.';
						END IF;
					ELSE
							
						SET strMsgName = 'group_invite_failed';
						SET strInviteConfirm = 'false';
						SET strInviteMsg = 'Error: User session incorrect.';
					END IF;
				ELSEIF nInviteSessionGroupID > 0
				THEN
							
					SET strMsgName = 'group_invite_failed';
					SET strInviteConfirm = 'false';
					SET strInviteMsg = 'Invited user already in session.';
				ELSE
							
					SET strMsgName = 'group_invite_failed';
					SET strInviteConfirm = 'false';
					SET strInviteMsg = 'Error: Invite could not be setup.';
				END IF;
			ELSE
						
				SET strMsgName = 'group_invite_failed';
				SET strInviteConfirm = 'false';
				SET strInviteMsg = 'User or invite name was invalid.';
			END IF;
		ELSE
					
			SET strMsgName = 'group_invite_failed';
			SET strInviteConfirm = 'false';
			SET strInviteMsg = 'User is not in a group.';
		END IF;
	ELSE
				
		SET strMsgName = 'group_invite_failed';
		SET strInviteConfirm = 'false';
		SET strInviteMsg = 'User and invite user can not be same.';
	END IF;

	CALL msg_send_three_param_proc(nTransID, 
								   nRespID, 
								   nClientID,
								   strMsgName,
								   'RCECORE',
								   'SessionGroupInviteConfirm',
								   strInviteConfirm,
								   strInviteMsg,
								   strSendUserName);
END //

CREATE PROCEDURE user_session_group_invite_finish_proc(strSendUserName VARCHAR(25), 
										   			   strInviteUserName VARCHAR(25), 
										   			   boolAccept BOOL, 
												  	   strGroupID VARCHAR(36),
												   	   nClientID INT(12),
												   	   nTransID INT(10), 
												   	   nRespID INT(10)) 
BEGIN
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE nInviteLoginID INT(10) DEFAULT 0;
	DECLARE nUserClientID INT(12) DEFAULT 0;
	DECLARE nSessionGroupID INT(12) DEFAULT 0;
	DECLARE strServerGroupID VARCHAR(36) DEFAULT '';
	DECLARE nInviteSessionGroupID INT(12) DEFAULT 0;
	DECLARE dtInviteExpired DATETIME DEFAULT NULL;
	DECLARE strMsgName VARCHAR(25) DEFAULT 'group_accept_confirmed';
	DECLARE strInviteConfirm VARCHAR(50) DEFAULT 'true';
	DECLARE strInviteMsg VARCHAR(50) DEFAULT 'Session group invite accepted successfully.';
	DECLARE nInviteMsgGroupID INT(10);
	DECLARE nInviteMsgID INT(10);
	DECLARE nSelectedID INT(10);
	DECLARE strInviteUserMsg MEDIUMBLOB;

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(nUserLoginID, strSendUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_session_group_invite_finish_proc - ', txErrorMsg));
   END;
  
   IF strSendUserName != strInviteUserName
   THEN
	
		IF strGroupID IS NULL OR strGroupID = ''
		THEN
   
			SELECT ul.user_login_id,
				   us.client_id,
				   usg.user_session_group_id
			FROM user_logins ul INNER JOIN user_sessions us ON us.user_login_id = ul.user_login_id
								INNER JOIN user_session_groups usg ON usg.user_login_id = ul.user_login_id
			WHERE ul.user_name = strSendUserName
			INTO nUserLoginID,
				 nUserClientID,
				 nSessionGroupID;
			
			SELECT user_login_id
			FROM user_logins
			WHERE user_name = strInviteUserName
			INTO nInviteLoginID;
		
			IF nUserLoginID > 0 AND nInviteLoginID > 0
			THEN
				
				SELECT usgi.user_session_group_invite_id,
					   usgi.date_expired,
					   usg.group_id
				FROM user_session_group_invites usgi INNER JOIN user_session_groups usg ON usg.user_session_group_id = usgi.user_session_group_id
				WHERE usgi.user_login_id = nInviteLoginID
				  AND usgi.user_session_group_id = nSessionGroupID
				INTO nInviteSessionGroupID,
					 dtInviteExpired,
					 strServerGroupID;

				IF nInviteSessionGroupID > 0 AND dtInviteExpired > NOW()
				THEN
				
					CALL RevComm_JSONMsgGroupCreate(CONCAT('finiv', CAST(nUserLoginID AS CHAR), CAST(nInviteLoginID AS CHAR)),
													nInviteMsgGroupID);
					CALL RevComm_JSONMsgCreate(nInviteMsgGroupID, 
											   'RCECORE', 
											   nInviteMsgID);
					     
				    IF boolAccept
				    THEN
				
						DELETE FROM user_session_group_invites 
						WHERE user_login_id = nInviteLoginID;
				    
						CALL RevComm_JSONMsgJSFuncCall(nInviteMsgID, 
												  	   'SessionGroupInviteInform', 
												  	   CONCAT('"', strInviteUserName, ' has joined."'), 
												  	   FALSE, 
												  	   nSelectedID);

						CALL RevComm_JoinGroup(nClientID, strServerGroupID);
			
						INSERT INTO user_session_group_users (user_login_id, user_session_group_id)
						VALUES (nInviteLoginID, nSessionGroupID);
				    ELSE
				    
				    	DELETE FROM user_session_group_invites 
						WHERE user_login_id = nInviteLoginID 
						  AND user_session_group_id = nSessionGroupID;
					    
						CALL RevComm_JSONMsgJSFuncCall(nInviteMsgID, 
												  	   'SessionGroupInviteInform', 
												  	   CONCAT('"', strInviteUserName, ' has declined."'), 
												  	   FALSE, 
												  	   nSelectedID);
				    END IF;

					CALL RevComm_JSONMsgJSFuncAddParam(nSelectedID, 
											  	   	   CONCAT('"', strInviteUserName, '"'), 
											  	   	   1,
											  	       FALSE);
					CALL RevComm_JSONMsgSaveClose(nInviteMsgID);
					CALL RevComm_JSONMsgsOutput(nInviteMsgGroupID, strInviteUserMsg);
					
					CALL RevComm_SendMsgUser(nUserClientID, strInviteUserMsg);
	
				ELSE
				
					DELETE FROM user_session_group_invites
					WHERE user_login_id = nInviteLoginID
					  AND date_expired <= NOW();
							
					SET strMsgName = 'group_finish_failed';
					SET strInviteConfirm = 'false';
					SET strInviteMsg = 'Session group invite expired.';
				
				END IF;
			ELSE
						
				SET strMsgName = 'group_finish_failed';
				SET strInviteConfirm = 'false';
				SET strInviteMsg = 'User or invite name was invalid.';
			END IF;
		ELSE
		
			DELETE FROM user_session_group_invites
			WHERE user_login_id = nInviteLoginID;
					
			SET strMsgName = 'group_finish_failed';
			SET strInviteConfirm = 'false';
			SET strInviteMsg = 'Already in a group.';
		END IF;
    ELSE
		
		SET strMsgName = 'group_finish_failed';
		SET strInviteConfirm = 'false';
		SET strInviteMsg = 'User and invite user can not be same.';
	END IF;

	IF boolAccept
	THEN
	
		CALL msg_send_three_param_proc(nTransID, 
									   nRespID, 
									   nClientID,
									   strMsgName,
									   'RCECORE',
									   'SessionGroupInviteFinish',
									   strInviteConfirm,
									   strInviteMsg,
									   strSendUserName);
	END IF;
END //

CREATE PROCEDURE user_session_group_check_proc(strSendUserName VARCHAR(25), 
										  	   strGroupID VARCHAR(36),
										   	   nClientID INT(12),
										   	   nTransID INT(10), 
										   	   nRespID INT(10)) 
BEGIN
	DECLARE nUserLoginID INT(10) DEFAULT 0;
	DECLARE strSessionGroupID VARCHAR(36)  DEFAULT '';
	DECLARE strServerGroupID VARCHAR(36) DEFAULT '';
	DECLARE strMsgName VARCHAR(25) DEFAULT 'group_check_confirmed';
	DECLARE strCheckConfirm VARCHAR(50) DEFAULT 'false';

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         IF txErrorMsg IS NULL
         THEN
         
         	SET txErrorMsg = "(NO MESSAGE FOUND)";
         END IF;
        
         CALL log_error_proc(nUserLoginID, strSendUserName, nClientID, nErrorNum, 
        					 CONCAT('PROCEDURE: user_session_group_check_proc - ', txErrorMsg));
    END;
	
	SELECT user_login_id,
		   group_id
	FROM user_session_groups
	WHERE user_name = strSendUserName
	INTO nUserLoginID,
		 strSessionGroupID;
	
	IF nUserLoginID > 0 
	THEN
	
		IF strSessionGroupID != strGroupID OR 
		   strSessionGroupID IS NULL OR
		   strGroupID IS NULL
		THEN
		
			IF strSessionGroupID != '' OR 
			   strSessionGroupID IS NOT NULL
			THEN
		
				DELETE FROM user_session_group_users
				WHERE user_login_id = nUserLoginID;
			
				DELETE FROM user_session_group_invites
				WHERE user_login_id = nUserLoginID;
			
				DELETE FROM user_session_groups 
				WHERE user_login_id = nUserLoginID;
			END IF;
		
			IF strGroupID != '' OR 
			   strGroupID IS NOT NULL
			THEN 
			
				INSERT INTO user_session_groups (user_login_id, group_id)
				VALUES (nUserLoginID, strGroupID);
			
				INSERT INTO user_session_group_users (user_login_id, user_session_group_id)
				VALUES (nUserLoginID, LAST_INSERT_ID());
			
				SET strSessionGroupID = strGroupID;
			END IF;
		END IF;

		IF strSessionGroupID = strGroupID AND  
		   strSessionGroupID IS NOT NULL AND
		   strGroupID IS NOT NULL
		THEN

			SET strCheckConfirm = 'true';
		END IF;
	ELSE

		SET strCheckConfirm = 'false';
	END IF;

	CALL msg_send_proc(nTransID, 
					   nRespID, 
					   nClientID,
					   strMsgName,
					   'RCECORE',
					   'SessionGroupCheckConfirm',
				  	   strCheckConfirm,
				  	   TRUE);
END //

CREATE PROCEDURE get_mobile_services_proc(nTransID INT(10), 
								  	      nRespID INT(10), 
								          nClientID INT(12))

BEGIN
	
	DECLARE nMobileServiceID INT(10) DEFAULT 0;
	DECLARE strMobileServiceName VARCHAR(25) DEFAULT "";
	DECLARE txReturnInfo TEXT DEFAULT "[";
	DECLARE boolNotFirstRecord BOOL DEFAULT FALSE; 
	DECLARE boolNotCompleted BOOL DEFAULT TRUE;

	DECLARE curMobileServices CURSOR
	FOR SELECT mobile_service_id,
			   mobile_service_name
	    FROM mobile_services;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET boolNotCompleted = FALSE;

	OPEN curMobileServices;

	LOOPMOBILESERVICES: LOOP

		FETCH curMobileServices
		INTO nMobileServiceID,
			 strMobileServiceName;
		
		IF boolNotCompleted
		THEN
		
			IF boolNotFirstRecord
			THEN
			
				SET txReturnInfo = CONCAT(txReturnInfo, ", ");
			ELSE 
			
				SET boolNotFirstRecord = TRUE;
			END IF;
		
			SET txReturnInfo = CONCAT(txReturnInfo, '{"ID": ', nMobileServiceID, ', ',  
													 '"NAME": "', strMobileServiceName, '"}');
		ELSE
		
			LEAVE LOOPMOBILESERVICES;
		END IF;
			
	END LOOP;

	CLOSE curMobileServices;
			
	SET txReturnInfo = CONCAT(txReturnInfo, "]");

	CALL msg_send_proc(nTransID, 
					   nRespID, 
					   nClientID,
					   'MOBILESERVICE',
					   'RCECORE',
					   'SetMobileService',
					   txReturnInfo,
					   FALSE);
END //

CREATE PROCEDURE msg_send_proc(nTransID INT(10), 
							   nRespID INT(10), 
							   nClientID INT(12),
							   strMsgOwnerName VARCHAR(25),
							   strClientObjDesign TEXT,
							   strFuncName VARCHAR(25),
							   txParamValue TEXT,
							   boolIsNotJSON BOOL)								
BEGIN
	
	DECLARE nMsgGroupID INT(10);
	DECLARE nMsgID INT(10);
	DECLARE nSelectedID INT(10);
	DECLARE strMsgInfo MEDIUMBLOB;
   
	CALL RevComm_JSONMsgGroupDataResultCreate(strMsgOwnerName, nClientID, nTransID, nRespID, nMsgGroupID);
	CALL RevComm_JSONMsgCreate(nMsgGroupID, strClientObjDesign, nMsgID);
	CALL RevComm_JSONMsgJSFuncCall(nMsgID, strFuncName, txParamValue, boolIsNotJSON, nSelectedID);
	CALL RevComm_JSONMsgSaveClose(nMsgID);
	CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
END //

CREATE PROCEDURE msg_send_two_param_proc(nTransID INT(10), 
								  	     nRespID INT(10), 
								         nClientID INT(12),
								         strMsgOwnerName VARCHAR(25),
								         strClientObjDesign TEXT,
								         strFuncName VARCHAR(25),
								         strParamValue1 VARCHAR(50),
								         strParamValue2 VARCHAR(50))								
BEGIN
	
	DECLARE nMsgGroupID INT(10);
	DECLARE nMsgID INT(10);
	DECLARE nSelectedID INT(10);
	DECLARE strMsgInfo MEDIUMBLOB;
   
	CALL RevComm_JSONMsgGroupDataResultCreate(strMsgOwnerName, nClientID, nTransID, nRespID, nMsgGroupID);
	CALL RevComm_JSONMsgCreate(nMsgGroupID, strClientObjDesign, nMsgID);
	CALL RevComm_JSONMsgJSFuncCall(nMsgID, strFuncName, strParamValue1, TRUE, nSelectedID);
	CALL RevComm_JSONMsgJSFuncAddParam(nSelectedID, strParamValue2, 1, TRUE);
	CALL RevComm_JSONMsgSaveClose(nMsgID);
	CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
END //

CREATE PROCEDURE msg_send_three_param_proc(nTransID INT(10), 
									  	   nRespID INT(10), 
									       nClientID INT(12),
									       strMsgOwnerName VARCHAR(25),
									       strClientObjDesign TEXT,
									       strFuncName VARCHAR(25),
									       strParamValue1 VARCHAR(50),
									       strParamValue2 VARCHAR(50),
									       strParamValue3 VARCHAR(50))								
BEGIN
	
	DECLARE nMsgGroupID INT(10);
	DECLARE nMsgID INT(10);
	DECLARE nSelectedID INT(10);
	DECLARE strMsgInfo MEDIUMBLOB;
   
	CALL RevComm_JSONMsgGroupDataResultCreate(strMsgOwnerName, nClientID, nTransID, nRespID, nMsgGroupID);
	CALL RevComm_JSONMsgCreate(nMsgGroupID, strClientObjDesign, nMsgID);
	CALL RevComm_JSONMsgJSFuncCall(nMsgID, strFuncName, strParamValue1, TRUE, nSelectedID);
	CALL RevComm_JSONMsgJSFuncAddParam(nSelectedID, strParamValue2, 1, TRUE);
	CALL RevComm_JSONMsgJSFuncAddParam(nSelectedID, strParamValue3, 2, TRUE);
	CALL RevComm_JSONMsgSaveClose(nMsgID);
	CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
END //

CREATE PROCEDURE log_error_proc(strLoginID INT(10),
								strUserName VARCHAR(25),
								nClientID INT(12),
								nErrorNum INT,
								txMsg BLOB)
BEGIN

	DECLARE nOutMaxChars SMALLINT UNSIGNED DEFAULT 65535;

	IF txMsg IS NOT NULL AND LENGTH(txMsg) <= nOutMaxChars
	THEN
	
		INSERT INTO error_logs (user_login_id, user_name, client_id, error_num, error_text)
        VALUES(strLoginID, strUserName, nClientID, nErrorNum, txMsg);

	ELSEIF txMsg IS NOT NULL
	THEN
	
		INSERT INTO error_logs (user_login_id, user_name, client_id, error_num, error_text)
        VALUES(strLoginID, 
       		   strUserName, 
       		   nClientID, 
       		   nErrorNum, 
       		   CONCAT('Original error message is too long. Message: ', SUBSTRING(txMsg, nOutMaxChars - 40),  '...'));

	ELSE 
	
		INSERT INTO error_logs (user_login_id, user_name, client_id, error_num, error_text)
        VALUES(strLoginID, 
       		   strUserName, 
       		   nClientID, 
       		   nErrorNum, 
       		   'Original error message was null.');
	END IF;	
END //

CREATE PROCEDURE bgmrpgm_down_reg_proc()
BEGIN

	DECLARE strFilePath TEXT;
	DECLARE strDesignation VARCHAR(25);
	DECLARE boolNotCompleted BOOL DEFAULT TRUE;

	DECLARE curDownloadFileNames CURSOR 
	FOR SELECT bgmrpgm_down_file_path,
		   	   bgmrpgm_down_file_designation
		FROM bgmrpgm_down_files;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET boolNotCompleted = FALSE;
		
	OPEN curDownloadFileNames;
	
	LOOPDOWNLOADFILES: LOOP
	
		FETCH curDownloadFileNames INTO strFilePath,
									 	strDesignation;
						
		IF boolNotCompleted
		THEN		

			CALL RevComm_RegisterFile(strDesignation, strFilePath);
		ELSE 

			LEAVE LOOPDOWNLOADFILES;
		END IF;
	END LOOP;
		
	CLOSE curDownloadFileNames;
	
END //

CREATE PROCEDURE bgmrpgm_down_info_proc(nTransID INT(10), 
									    nRespID INT(10), 
									    nClientID INT(12), 
									    strFileDesign VARCHAR(25),
									    strFilePath VARCHAR(25), 
									    nTimeLimit INT(10))
BEGIN
	
	DECLARE nMsgGroupID INT(10) DEFAULT NULL;
	DECLARE nMsgID INT(10) DEFAULT NULL;
	DECLARE nFuncID INT(10) DEFAULT NULL;		
	DECLARE strFileType VARCHAR(25); 
	DECLARE strMsgInfo MEDIUMBLOB;

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         CALL store_error_proc(CONCAT('Action: Getting download information. Exception: ', nErrorNum, ' - ', txErrorMsg)); 

		 CALL RevComm_JSONMsgGroupDataResultCreate('download_info', nClientID, nTransID, nRespID, nMsgGroupID);
	
		 IF nMsgGroupID IS NOT NULL 
		 THEN
		
			 CALL RevComm_JSONMsgCreate(nMsgGroupID, 'MAIN', nMsgID);
		
			 IF nMsgID IS NOT NULL 
			 THEN
			 
				 CALL RevComm_JSONMsgJSFuncCall(nMsgID, "Log", '["Database error occurred.", true]', FALSE, nFuncID);
				 CALL RevComm_JSONMsgSaveClose(nMsgID);
				 CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
		
			 ELSE 
				 CALL store_error_proc('Action: Getting download information. Starting "MAIN" message for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
			 END IF;
	
		 ELSE 
			 CALL store_error_proc('Action: Getting download information. Starting message group for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
		 END IF;
    END;
    
    START TRANSACTION;

		BEGIN
			
  			SELECT bgmrpgm_down_file_type
 			INTO strFileType
			FROM bgmrpgm_down_files
 			WHERE bgmrpgm_down_file_designation = strFileDesign;
		
		 	CALL RevComm_JSONMsgGroupDataResultCreate('download_info', nClientID, nTransID, nRespID, nMsgGroupID);
		
		 	IF nMsgGroupID IS NOT NULL 
		 	THEN		
			
			 	CALL RevComm_JSONMsgCreate(nMsgGroupID, 'BGMRPGMCORE', nMsgID);
		
			 	IF nMsgID IS NOT NULL 
			 	THEN
			 
				 	CALL RevComm_JSONMsgJSFuncCall(nMsgID, 'DownloadStart', strFileDesign, TRUE, nFuncID);
		
				 	IF nFuncID IS NOT NULL
				 	THEN
			 
				    	CALL RevComm_JSONMsgJSFuncAddParam(nFuncID, strFileType, 1, TRUE);
				    	CALL RevComm_JSONMsgJSFuncAddParam(nFuncID, strFilePath, 2, TRUE);
				    	CALL RevComm_JSONMsgJSFuncAddParam(nFuncID, nTimeLimit, 3, TRUE);
					 	CALL RevComm_JSONMsgSaveClose(nMsgID);
						CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
			
				 	ELSE 
					 	CALL store_error_proc('Action: Getting download information. Starting "BGMRPGMCORE" message''s function call for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
				 	END IF;
			 	ELSE 
				 	CALL store_error_proc('Action: Getting download information. Starting "BGMRPGMCORE" message for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
			 	END IF;
				
		 	ELSE 
			 	CALL store_error_proc('Action: Getting download information. Starting message group for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
		 	END IF;
		
		END;
	
	COMMIT;
END //

CREATE PROCEDURE bgmrpgm_down_vers_proc(nTransID INT(10), 
									    nRespID INT(10), 
									    nClientID INT(12), 
									    strGameName VARCHAR(25), 
									    strVersion VARCHAR(25), 
									    strFilePath VARCHAR(25), 
									    nTimeLimit INT(10))
BEGIN
	
	DECLARE nMsgGroupID INT(10) DEFAULT NULL;
	DECLARE nMsgID INT(10) DEFAULT NULL;
	DECLARE nFuncID INT(10) DEFAULT NULL;		
	DECLARE strFileDesign VARCHAR(25); 	
	DECLARE fVersion FLOAT(5,5) DEFAULT 0.0; 
	DECLARE strMsgInfo MEDIUMBLOB;
	DECLARE boolNotCompleted BOOL DEFAULT TRUE;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET boolNotCompleted = FALSE;

   	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   	BEGIN
	   	
	   	 DECLARE nErrorNum INT;
  		 DECLARE txErrorMsg TEXT;

         GET DIAGNOSTICS CONDITION 1 nErrorNum = MYSQL_ERRNO, txErrorMsg = MESSAGE_TEXT;
        
         CALL store_error_proc(CONCAT('Action: Getting download version information. Exception: ', nErrorNum, ' - ', txErrorMsg)); 

		 CALL RevComm_JSONMsgGroupDataResultCreate('download_version', nClientID, nTransID, nRespID, nMsgGroupID);
	
		 IF nMsgGroupID IS NOT NULL 
		 THEN
		
			 CALL RevComm_JSONMsgCreate(nMsgGroupID, 'MAIN', nMsgID);
		
			 IF nMsgID IS NOT NULL 
			 THEN
			 
				 CALL RevComm_JSONMsgJSFuncCall(nMsgID, "Log", '["Database error occurred.", true]', FALSE, nFuncID);
				 CALL RevComm_JSONMsgSaveClose(nMsgID);
				 CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
		
			 ELSE 
				 CALL store_error_proc('Action: Getting download version information. Starting "MAIN" message for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
			 END IF;
	
		 ELSE 
			 CALL store_error_proc('Action: Getting download version information. Starting message group for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
		 END IF;
    END;
   
    IF strVersion IS NOT NULL AND strVersion <> ''
    THEN
    
	    START TRANSACTION;
	
			BEGIN
				
	  			DECLARE curDownloadFiles CURSOR
	 			FOR SELECT bdf.bgmrpgm_down_file_designation
					FROM bgmrpgm_down_files bdf
	 				WHERE bdf.bgmrpgm_down_game_version_id IN (SELECT bdgv.bgmrpgm_down_game_version_id 
	 														   FROM bgmrpgm_down_game_versions bdgv INNER JOIN bgmrpgm_down_games bdgm ON bdgm.bgmrpgm_down_game_name = strGameName 
	 														   																		  AND bdgm.bgmrpgm_down_game_id = bdgv.bgmrpgm_down_game_id
	 														   WHERE bdgv.bgmrpgm_down_game_version_number > CAST(strVersion AS DECIMAL(5,5)));
						
				OPEN curDownloadFiles;
				
				LOOPDOWN: LOOP
				
					FETCH curDownloadFiles INTO strFileDesign;
									
					IF boolNotCompleted
					THEN		
					
					 	CALL bgmrpgm_down_info_proc(nTransID, nRespID, nClientID, strFileDesign, nTimeLimit);
	
					ELSE 
					
						SET boolNotCompleted = TRUE;
						LEAVE LOOPDOWN;
					END IF;
				END LOOP;
			
				CLOSE curDownloadFiles;
			END;
		
			BEGIN
			
	  			SELECT MAX(bdgv.bgmrpgm_down_game_version_number)
	 			INTO fVersion
	 			FROM bgmrpgm_down_game_versions bdgv INNER JOIN bgmrpgm_down_games bdgm ON bdgm.bgmrpgm_down_game_name = strGameName 
	 														   						   AND bdgm.bgmrpgm_down_game_id = bdgv.bgmrpgm_down_game_id;
			
	 			IF fVersion > 0.0
	 			THEN
	 			
				 	CALL RevComm_JSONMsgGroupDataResultCreate('download_version', nClientID, nTransID, nRespID, nMsgGroupID);
				
				 	IF nMsgGroupID IS NOT NULL 
				 	THEN		
					
					 	CALL RevComm_JSONMsgCreate(nMsgGroupID, 'BGMRPGMCORE', nMsgID);
				
					 	IF nMsgID IS NOT NULL 
					 	THEN
					 
						 	CALL RevComm_JSONMsgJSFuncCall(nMsgID, 'DownloadVersion', fVersion, TRUE, nFuncID);
				 			CALL RevComm_JSONMsgsOutput(nMsgGroupID, strMsgInfo);
					 	ELSE 
						 	CALL store_error_proc('Action: Getting download version information. Starting "BGMRPGMCORE" message for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
					 	END IF;
						
				 	ELSE 
					 	CALL store_error_proc('Action: Getting download version information. Starting message group for transaction ID, ', nTransID, ', and response ID, ', nRespID, ' failed.');
				 	END IF;
			 	ELSE 
				 	CALL store_error_proc('Action: Getting download version information. The next version was not found for transaction ID, ', nTransID, ', and response ID, ', nRespID, '.');
			 	END IF;
			
			END;
			
		COMMIT;
	ELSE
	
		CALL store_error_proc('Action: Getting download version information. Invalid version value was sent for transaction ID, ', nTransID, ', and response ID, ', nRespID, '.');
    END IF;
END //

CREATE PROCEDURE store_error_proc(txMsg BLOB)
BEGIN

	DECLARE nOutMaxChars SMALLINT UNSIGNED DEFAULT 65535;

	IF txMsg IS NOT NULL AND LENGTH(txMsg) <= nOutMaxChars
	THEN
	
		INSERT INTO error_logs (error_text) VALUES (txMsg);
	ELSEIF txMsg IS NOT NULL
	THEN
	
		INSERT INTO error_logs (error_text) VALUES (CONCAT('Original error message is too long. Message: ', SUBSTRING(txMsg, nOutMaxChars - 40),  '...'));
	ELSE 

		INSERT INTO error_logs (error_text) VALUES ('Original error message was null.');
	END IF;	
END //

DELIMITER ;

INSERT INTO mobile_services (mobile_service_name, service_url)
VALUES ('AT&T', 'txt.att.net'),
('Boost Mobile', 'ms.myboostmobile.com'),
('Cricket Wireless', 'mms.cricketwireless.net'),
('Google Project Fi', 'msg.fi.google.com'),
('Republic Wireless', 'text.republicwireless.com'),
('Sprint', 'messaging.sprintpcs.com'),
('Straight Talk', 'vtext.com'),
('T-Mobile', 'tmomail.net'),
('Tracfone', 'mmst5.tracfone.com'),
('U.S. Cellular', 'mms.uscc.net'),
('Verizon', 'vtext.com'),
('Virgin Mobile', 'vmobl.com');