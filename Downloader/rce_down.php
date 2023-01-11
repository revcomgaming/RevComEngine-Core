<?php
/* bgmrpgm_down.php - Server Page for Managing Files Being Used in RevCommSuite's
                      Download Functionality
  
 MIT License

 Copyright (c) 2023 RevComGaming

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. */

include_once 'RevCommData.php';
include_once 'RevCommMain.php';

define("SLASH", $CONFIG -> SystemSlashReplace('/'));
                                    /* System Directory Slash Character */

$strGameID;                         /* Selected Game ID */
$strVersionID;                      /* Selected Game's Version ID */
$nFileID;                           /* Selected File ID */
// $strVersNextInsert = 'INSERT INTO bgmrpgm_down_game_versions (bgmrpgm_down_game_id,
//                                                               bgmrpgm_down_game_version_number)
//                       SELECT bdgv.bgmrpgm_down_game_id,
//                              ? + ?
//                       FROM bgmrpgm_down_game_versions bdgv
//                       WHERE bdgv.bgmrpgm_down_game_id = ?';
                                    /* Database Statement for Next Version Number */
$aGames;                            /* List of Games */
$aVersions;                         /* List of Game's Versions */
$aFiles;                            /* List of Game's Versions Files */
//$aFileDesignCheck;                /* Used for File Designation Check */
$strServerFileFolderPath = $CONFIG -> server_file_folder_path;
                                    /* Path to Server Folder for Files */
$aFileTypes = explode(',', $CONFIG -> server_file_types);
                                    /* Server File Types */
$strErrorMsg = "";                  /* Error Message */
$boolNoError = true;                /* Indicator That No Error Has Occurred */

if (isset($_POST["gamenew"]) && !empty($_POST["gamenew"])) {
    
    if (!$DATA -> QuerySafeParam("SELECT bgmrpgm_down_game_id
			                      FROM bgmrpgm_down_games
                                  WHERE bgmrpgm_down_game_name = ?", $_POST["gamenew"], $aGames)) {
                                 
        if (!$DATA -> ExecuteSafeParam("INSERT INTO bgmrpgm_down_games (bgmrpgm_down_game_name) VALUES (?)", $_POST["gamenew"])) {
            
            $strErrorMsg = "New game, '" . $_POST["gamenew"] . "', could not be created.";
        }
    }
    else {
        
        $strErrorMsg = "New game, '" . $_POST["gamenew"] . "', could not be created, name already exists.";
    }
}

if (isset($_POST["filedelete"]) && !empty($_POST["filedelete"])) {
    
    if ($DATA -> QuerySafeParam("SELECT bdf.bgmrpgm_down_file_id,
                                        bdf.bgmrpgm_down_file_path
                                 FROM bgmrpgm_down_files bdf
                                 WHERE bdf.bgmrpgm_down_file_id = ?", $_POST["filedelete"], $aFiles)) {
                                                                            
        $boolNoError = DeleteFiles($aFiles);
        
        unset($aFiles);
    }
}

if (isset($_POST["versiondelete"]) && !empty($_POST["versiondelete"])) {
 
    if ($DATA -> QuerySafeParam("SELECT bdf.bgmrpgm_down_file_id,
                                        bdf.bgmrpgm_down_file_path
                                 FROM bgmrpgm_down_files bdf
                                 WHERE bdf.bgmrpgm_down_game_version_id = ?", $_POST["versiondelete"], $aFiles)) {
                                                                            
        $boolNoError = DeleteFiles($aFiles);
                                    
        unset($aFiles);
    }
    
    if ($boolNoError) {
     
        if ($DATA -> ExecuteSafeParam("DELETE FROM bgmrpgm_down_game_versions
    				                   WHERE bgmrpgm_down_game_version_id = ?", $_POST["versiondelete"], true)) {
        
            if (strlen($strServerFileFolderPath) > 1 && substr($strServerFileFolderPath, 0, -1) != SLASH) {
               
               $strServerFileFolderPath .= SLASH;
            }
            
            if (file_exists($strServerFileFolderPath . $_POST["gameselect"] . SLASH . $_POST["versiondelete"]) &&
                !rmdir($strServerFileFolderPath . $_POST["gameselect"] . SLASH . $_POST["versiondelete"])) {
                
                $strErrorMsg = "Deleting version directory from server failed.";
                $boolNoError = false;
            }
        }
        else {
            
            $strErrorMsg = "Deleting version failed.";
            $boolNoError = false;
        }
    }
    else if (!$boolNoError) {
        
        $strErrorMsg = "Deleting file information during version deletion failed.";
        $boolNoError = false;
    }
    
    unset($_POST["versionselect"]);
}

if (isset($_POST["gamedelete"]) && !empty($_POST["gamedelete"])) {
    
    if ($DATA -> QuerySafeParam("SELECT bdf.bgmrpgm_down_file_id,
                                        bdf.bgmrpgm_down_file_path
                                 FROM bgmrpgm_down_files bdf
                                 WHERE bdf.bgmrpgm_down_game_version_id IN (SELECT bdgv.bgmrpgm_down_game_version_id 
                                                                            FROM bgmrpgm_down_game_versions bdgv 
                                                                            WHERE bdgv.bgmrpgm_down_game_id = ?)", $_POST["gamedelete"], $aFiles)) {
    
        $boolNoError = DeleteFiles($aFiles);
        
        unset($aFiles);
    }
    
    if ($boolNoError) {
        
        if (strlen($strServerFileFolderPath) > 1 && substr($strServerFileFolderPath, 0, -1) != SLASH) {
            
            $strServerFileFolderPath .= SLASH;
        }
        
        if ($DATA -> QuerySafeParam("SELECT bgmrpgm_down_game_version_id,
                                            bgmrpgm_down_game_version_number 
                                     FROM bgmrpgm_down_game_versions
    				                 WHERE bgmrpgm_down_game_id = ?", $_POST["gamedelete"], $aVersions)) {
                                                                                
            foreach ($aVersions as $objVersion) {
                
                if (file_exists($strServerFileFolderPath . $_POST["gamedelete"] . SLASH . $objVersion -> bgmrpgm_down_game_version_id) && 
                    !rmdir($strServerFileFolderPath . $_POST["gamedelete"] . SLASH . $objVersion -> bgmrpgm_down_game_version_id)) {
                    
                    $strErrorMsg = "Deleting game's version directories from server failed.";
                    $boolNoError = false;
                    break;
                }
            }
        }
        
        $DATA -> ExecuteSafeParam("DELETE FROM bgmrpgm_down_game_versions
    				               WHERE bgmrpgm_down_game_id = ?", $_POST["gamedelete"], true);
        
        if ($DATA -> ExecuteSafeParam("DELETE FROM bgmrpgm_down_games
        				               WHERE bgmrpgm_down_game_id = ?", $_POST["gamedelete"], true)) {
        				               
            if ($boolNoError && 
                file_exists($strServerFileFolderPath . $_POST["gamedelete"]) &&
                !rmdir($strServerFileFolderPath . $_POST["gamedelete"])) {
               
               $strErrorMsg = "Deleting game directory from server failed.";
               $boolNoError = false;
            }
        }
        else {
        				                    
            $strErrorMsg = "Deleting game information failed.";
            $boolNoError = false;
        }
    }
    else {
        
        $strErrorMsg = "Deleting file information during game deletion failed.";
        $boolNoError = false;
    }
    
    unset($_POST["versionselect"]);
    unset($_POST["gameselect"]);
}

if ($DATA -> Query("SELECT bgmrpgm_down_game_id,
					       bgmrpgm_down_game_name
			        FROM bgmrpgm_down_games", $aGames)) {

	if (isset($_POST["gameselect"]) && !empty($_POST["gameselect"])) {
        
	    $strGameID = $_POST["gameselect"];
	}
	else if (!empty($aGames)) {
	    
	    $strGameID = $aGames[0] -> bgmrpgm_down_game_id;
	}
	    
	if ((isset($strGameID) && !empty($strGameID))) {
        
        if ($DATA -> QuerySafeParam("SELECT bgmrpgm_down_game_version_id,
                                            bgmrpgm_down_game_version_number
							         FROM bgmrpgm_down_game_versions 
						             WHERE bgmrpgm_down_game_id = ?
                                     ORDER BY bgmrpgm_down_game_version_number DESC", $strGameID, $aVersions)) {
						             
             if (isset($_POST["versionselect"]) && !empty($_POST["versionselect"])) {
                 
                 $strVersionID = $_POST["versionselect"];
             }
             else {
                 
                 $strVersionID = $aVersions[0] -> bgmrpgm_down_game_version_id;
             }
             
             $DATA -> QuerySafeParam("SELECT bgmrpgm_down_file_id,
                                             bgmrpgm_down_file_designation,
                                             bgmrpgm_down_file_path
                                      FROM bgmrpgm_down_files
                                      WHERE bgmrpgm_down_game_version_id = ?", $strVersionID, $aFiles);
        }
        
        if (((isset($_POST["versionpoint"]) && !empty($_POST["versionpoint"])) ||
            (isset($_POST["versionnext"]) && !empty($_POST["versionnext"])))) {
        
            if (!empty($aVersions)) {
                
                $strVersNextInsert = 'INSERT INTO bgmrpgm_down_game_versions (bgmrpgm_down_game_id,
                                                                              bgmrpgm_down_game_version_number)
                                      SELECT bdgv.bgmrpgm_down_game_id,
                                             ? + ?
                                      FROM bgmrpgm_down_game_versions bdgv
                                      WHERE bdgv.bgmrpgm_down_game_id = ? 
                                        AND bdgv.bgmrpgm_down_game_version_id = ?';
                
                if (isset($_POST["versionpoint"]) &&
                    !empty($_POST["versionpoint"]) &&
                    !($strVersionID = $DATA -> ExecuteSafeParam($strVersNextInsert, [$aVersions[0] -> bgmrpgm_down_game_version_number,
                                                                                     $_POST["versionpoint"],
                                                                                     $strGameID, 
                                                                                     $strVersionID]))) {
                            
                    $strErrorMsg = "New point release could not be created. Database error.";
                    $boolNoError = false;
                }
                else if (isset($_POST["versionnext"]) &&
                         !empty($_POST["versionnext"]) &&
                         !($strVersionID = $DATA -> ExecuteSafeParam($strVersNextInsert, [floor($aVersions[0] -> bgmrpgm_down_game_version_number),
                                                                                          $_POST["versionnext"],
                                                                                          $strGameID,
                                                                                          $strVersionID]))) {
                            
                    $strErrorMsg = "New version could not be created. Database error.";
                    $boolNoError = false;
                }
                
                if (!empty($strVersionID)) {
                    
                    $DATA -> QuerySafeParam("SELECT bgmrpgm_down_game_version_id,
                                                    bgmrpgm_down_game_version_number
        						             FROM bgmrpgm_down_game_versions
        					                 WHERE bgmrpgm_down_game_id = ?
                                             ORDER BY bgmrpgm_down_game_version_number DESC", $strGameID, $aVersions);
                }
            }
            else if ($strVersionID = $DATA -> ExecuteSafeParam("INSERT INTO bgmrpgm_down_game_versions (bgmrpgm_down_game_id,
                                                                                                        bgmrpgm_down_game_version_number)
                                                                VALUES (?, 0.0)", $strGameID)) {
                                                           
                $aVersions = [(object)['bgmrpgm_down_game_version_id' => $strVersionID,
                                       'bgmrpgm_down_game_version_number' => '0.00000']];
            }
            else {
                
                $strErrorMsg = "First version could not be created.";
                $boolNoError = false;
            }
        }
        
        if (isset($strVersionID) && !empty($strVersionID)) {
            
            if ($DATA -> QuerySafeParam("SELECT bgmrpgm_down_file_id,
                                                bgmrpgm_down_file_designation,
                                                bgmrpgm_down_file_path
                                         FROM bgmrpgm_down_files 
                                         WHERE bgmrpgm_down_game_version_id = ?", $strVersionID, $aFiles)) {
                                          
                if (isset($_POST["fileselect"]) && !empty($_POST["fileselect"])) {
                      
                    $nFileID = (int)$_POST["fileselect"];
                
                    foreach ($aFiles as $objFileInfo) {
                        
                        if ((int)$objFileInfo -> bgmrpgm_down_file_id == $nFileID) {
                            
                            if (file_exists($objFileInfo -> bgmrpgm_down_file_path)) {
                                
                                if (unlink($objFileInfo -> bgmrpgm_down_file_path)) {
                                
                                    if (!$DATA -> ExecuteSafeParam("DELETE FROM bgmrpgm_down_files
                                                                    WHERE bgmrpgm_down_file_id = ?", $nFileID, true)) {
                                                                    
                                        $strErrorMsg = "Deleting file information, '" .
                                                       basename($objFileInfo -> bgmrpgm_down_file_path) . 
                                                       "', during version deletion from database failed.";
                                        $boolNoError = false;
                                    }
                                }
                                else {
                                    
                                    $strErrorMsg = "Deleting file, '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                                                   "', during version deletion from server failed.";
                                    $boolNoError = false;
                                }
                            }
                            else if ($DATA -> ExecuteSafeParam("DELETE FROM bgmrpgm_down_files
                                                                WHERE bgmrpgm_down_file_id = ?", $nFileID, true)) {
                                                                 
                                $strErrorMsg = "File, '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                                               "' was not found on the server, but file information was deleted from database successfully.";
                                $boolNoError = false;
                            }
                            else {
                                
                                $strErrorMsg = "File, '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                                               "' was not found on the server, and deleting file information from database failed.";
                                $boolNoError = false;
                            }
                            
                            break;
                        }
                    }
                    
                    if ($boolNoError) {
                        
                        $DATA -> QuerySafeParam("SELECT bgmrpgm_down_file_id,
                                                        bgmrpgm_down_file_designation,
                                                        bgmrpgm_down_file_path
                                                 FROM bgmrpgm_down_files
                                                 WHERE bgmrpgm_down_game_version_id = ?", $strVersionID, $aFiles);
                    }
                }
            }
        }
    }
}

if (isset($_POST["filedesignation"]) && !empty($_POST["filedesignation"]) &&
    isset($_FILES["filenew"]) && !empty($_FILES["filenew"])) {
        
    $aFileDesignCheck;
        
    if (!$DATA -> QuerySafeParam("SELECT bgmrpgm_down_file_id
                                  FROM bgmrpgm_down_files
                                  WHERE bgmrpgm_down_file_designation = ?", $_POST["filedesignation"], $aFileDesignCheck)) {
                                  
        if (strlen($strServerFileFolderPath) > 1 && substr($strServerFileFolderPath, 0, -1) != SLASH) {
          
            $strServerFileFolderPath .= SLASH;
        }
        
        $strServerFileFolderPath .= $_POST["gameselect"] . SLASH . $_POST["versionselect"] . SLASH;
        
        if (!file_exists($strServerFileFolderPath)) {
            
            if (!mkdir($strServerFileFolderPath, 777, true)) {
                
                $strErrorMsg = "Uploading file failed due to directory path, '" . $strServerFileFolderPath . "', could not be created.";
                $boolNoError = false;
            }
        }
        
        if ($boolNoError) {
            
            $strServerFileFolderPath .= $_FILES["filenew"]["name"];
            
            if ($DATA -> ExecuteSafeParam("INSERT INTO bgmrpgm_down_files (bgmrpgm_down_file_designation, 
                                                                           bgmrpgm_down_file_type, 
                                                                           bgmrpgm_down_file_path,
                                                                           bgmrpgm_down_game_version_id) 
                                           VALUES (?, ?, ?, ?)", [$_POST["filedesignation"], 
                                                                  $_POST["filetype"], 
                                                                  $_POST["gameselect"] . SLASH . $_POST["versionselect"] . SLASH . $_FILES["filenew"]["name"], 
                                                                  $_POST["versionselect"]])) {
              
                if (file_exists($strServerFileFolderPath)) {
                   
                    if (!unlink($strServerFileFolderPath)) {
                        
                        $strErrorMsg = "Uploading file failed to deleting existing file, '" . basename($strServerFileFolderPath) . "', from server.";
                        $boolNoError = true;
                    }
                }
                
                if ($boolNoError && !move_uploaded_file($_FILES["filenew"]["tmp_name"], $strServerFileFolderPath)) {
                    
                    $strErrorMsg = "Uploading file, '" . basename($strServerFileFolderPath) . "', during transfer on server.";
                    $boolNoError = true;
                }
                
                if ($boolNoError) {
                    
                    $DATA -> QuerySafeParam("SELECT bgmrpgm_down_file_id,
                                                    bgmrpgm_down_file_designation,
                                                    bgmrpgm_down_file_path
                                             FROM bgmrpgm_down_files
                                             WHERE bgmrpgm_down_game_version_id = ?", $_POST["versionselect"], $aFiles);
                }
            }
            else {
                
                $strErrorMsg = "Uploading file, '" . basename($strServerFileFolderPath) . "', failed due failure to insert file information into database.";
                $boolNoError = true;
            }
        }
    }
    else {
        
        $strErrorMsg = "Uploading file, '" . basename($strServerFileFolderPath) . "', failed due to file designation, '" . 
                       $_POST["filedesignation"]. "' already existing in the database.";
        $boolNoError = true;
    }
}
else if (isset($_POST["filedesignation"]) && empty($_POST["filedesignation"]) ||
         isset($_FILES["filenew"]) && empty($_FILES["filenew"])) { 
                  
    $strErrorMsg = "Uploading file failed due to file or its designation not being set.";
    $boolNoError = true;
}

function DeleteFiles($aFileList) {
    
    global $DATA;
    global $strErrorMsg;
    $boolSuccess = true;            /* Indicator That Files Where Successfully Deleted */
    
    foreach ($aFileList as $objFileInfo) {
        
        if (file_exists($objFileInfo -> bgmrpgm_down_file_path)) {
            
            if (unlink($objFileInfo -> bgmrpgm_down_file_path)) {
                
                if (!$DATA -> Execute("DELETE FROM bgmrpgm_down_files
                                       WHERE bgmrpgm_down_file_id = " . $objFileInfo -> bgmrpgm_down_file_id, true)) {
                                       
                    $strErrorMsg = "Deleting file '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                                   "' from database failed after the file was deleting from the server.";        
                    $boolSuccess = false;
                }
            }
            else {
                
                $strErrorMsg = "Deleting file '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                               "' failed due to failure to delete from the server.";        
                $boolSuccess = false;
            }
        }
        else if (!$DATA -> Execute("DELETE FROM bgmrpgm_down_files
                                    WHERE bgmrpgm_down_file_id = " . $objFileInfo -> bgmrpgm_down_file_id, true)) {
                                   
            $strErrorMsg = "Deleting file '" . basename($objFileInfo -> bgmrpgm_down_file_path) . 
                           "' from database was successful after the file was not found on the server.";        
        }
        else {
            
            $strErrorMsg = "Deleting file '" . basename($objFileInfo -> bgmrpgm_down_file_path) .
                           "' failed due to failure to delete from the server.";  
        }
    }
    
    return $boolSuccess;
}
?>
 
<html>
	<head>
		<style type="text/css">
		  body {
		  
		      text-align: center;
		  }
		  
		  div {
		   
		      width: 100%;
		      padding: 10px 0px;
		  }
		  
		  div#ErrorLayer {
		  
		      background-color: yellow;
		      border-style: solid;
		      border: 5px 0px;
		      border-color: red;
		  }
		  
		  div.LeadPanelLayer {
		  
		      border-top: 2px;
		      border-top-style: solid;
		      border-color: grey;
		      padding-bottom: 10px
		  }
		  
		  table {
		  
		      padding-left: 40%
		  }
		  
		  table td {
		  
		      padding-right: 10px
		  }
		  
		  span.ErrorStart {
		  
		      font-weight: bold;
		  }
		</style>
	</head>
	<body>
		<?php 
				    
		    if (!empty($strErrorMsg)) {
	    ?>
        		<div id="ErrorLayer">	
        			<span class="ErrorStart">ERROR: </span>
        			<span class="ErrorMsg"><?=$strErrorMsg ?></span>
        		</div>
		<?php 
				    
		     }
	    ?>
		<div>	
			<form name="gamenewform" method="post">
				<label for="gamenew">Create Game:</label>
    			<input type="text" id="gamenew" name="gamenew" value="" maxlength="25" />
    			<input type="submit" />
			</form>
		</div>
		<?php 
				    
		     if (!empty($aGames)) {
	    ?>
                <form name="gameselectform" method="post">
            		<div class="LeadPanelLayer">
						<label for="gameselect">Select Game:</label>
            			<select id="gameselect" name="gameselect" onchange="if (this.form.versionselect) { this.form.versionselect.selectedIndex = -1; } this.form.submit();">			        
            				<?php 
            				    foreach ($aGames as $objGameInfo) {
            				            
            				        echo '<option value="' . $objGameInfo -> bgmrpgm_down_game_id . '"';
            				        
            				        if ($strGameID == $objGameInfo -> bgmrpgm_down_game_id) {

                                        echo ' selected';            				            
            				        }
            				        
            				        echo '>' . $objGameInfo -> bgmrpgm_down_game_name . '</option>';
            				    }
            				?>
            			</select>
            		</div>
            		<div>
                		<?php 
                				    
                		  if (!empty($aVersions)) {
                	    ?>            	    
							<label for="versionselect">Select Version:</label>
                			<select id="versionselect" name="versionselect" onchange="this.form.submit();">
                				        
                				<?php 
                				
            				        foreach ($aVersions as $objVersionInfo) {
            				            
            				            echo '<option value="' . $objVersionInfo -> bgmrpgm_down_game_version_id . '"';
            				            
            				            if ($strVersionID == $objVersionInfo -> bgmrpgm_down_game_version_id) {
            				                
            				                echo ' selected';
            				            }
            				            
            				            echo '>' . substr($objVersionInfo -> bgmrpgm_down_game_version_number, 0, -4) . '</option>';
            				        }
                				?>
                			</select>
            			
            			<?php 
                		     }
                		?>
            		</div>
            		<div>	
                		<button id="versionpoint" name="versionpoint" value="" onclick="this.value = .1; this.form.submit();">Create Point Release</button>
                		<button id="versionnext" name="versionnext" value="" onclick="this.value = 1; this.form.submit();">Create New Version</button>
        		
        				<?php 
        				
    				        if (!empty($aVersions)) {
    				    ?>
                				<button name="versiondelete" id="versiondelete" value="" 
                	 			 onclick="if (confirm('Do you want to delete this version and it\'s files?')) { this.value = this.form.versionselect.options[this.form.versionselect.selectedIndex].value; this.form.submit(); }">
                	 				DELETE VERSION
                				</button>
        				<?php 
        				
    				        }
    				    ?>		
    				    
    				    <?php 
        				
    				        if (!empty($aGames)) {
    				    ?>
                				<button name="gamedelete" if="gamedelete" value="" 
                	 			 onclick="if (confirm('Do you want to delete this game\'s version and files?')) { this.value = this.form.gameselect.options[this.form.gameselect.selectedIndex].value; this.form.submit(); }">
                	 				DELETE GAME
                				</button>
        				<?php 
        				
    				        }
    				    ?>
            		</div>
                </form>
		<?php 
		     }
		  
		     if (!empty($aFiles)) {
		        
		?>
                <form name="fileselectform" method="post">
                	<div class="LeadPanelLayer">
						<label for="fileselect">Select File:</label>
            			<select id="fileselect" name="fileselect">
            				        
            				<?php 
            				
            				    foreach ($aFiles as $objFileInfo) {
        				            
            				        echo '<option value="' . $objFileInfo -> bgmrpgm_down_file_id . '">' . 
            				             $objFileInfo -> bgmrpgm_down_file_designation . ": " . 
        				                 basename($objFileInfo -> bgmrpgm_down_file_path) . '</option>';
        				        }
            				?>
            			</select>
    				</div>
    				<div>          		
    	            	<button name="filedelete" onclick="if (confirm('Do you want to delete?')) { this.form.submit(); }">DELETE</button>
    					<input type="hidden" id="gameselect" name="gameselect" value="<?=$strGameID ?>" />
                		<input type="hidden" id="versionselect" name="versionselect" value="<?=$strVersionID ?>" />
    				</div>
    			</form>
		<?php 
		         
		     }
		     
		     if (isset($strVersionID) && !empty($strVersionID)) {
		?>
		
				<form name="filenewform" method="post" enctype="multipart/form-data">
					<div class="LeadPanelLayer">
						<span>Upload File:</span>
					</div>
					<div>
						<table>
							<tr>
								<td>
	        						<label for="filetype">Select File Type:</label>
	        					</td>
	        					<td>
                    				<select id="filetype" name="filetype">
                        				        
                        				<?php 
                        				
                        				    foreach ($aFileTypes as $strType) {
                    				            
                        				        echo '<option value="' . trim($strType) . '">' . trim($strType) . '</option>';
                    				        }
                        				?>
                        			</select>
                    			</td>
							</tr>
							<tr>
								<td>
									<label for="filedesignation">File Designation:</label>
	        					</td>
	        					<td>
									<input type="text" id="filedesignation" name="filedesignation" maxlength="25" />
                    			</td>
							</tr>
							<tr>
								<td>
									<label for="filenew">Select File:</label>
	        					</td>
	        					<td>
									<input type="file" id="filenew" name="filenew" />
                    			</td>
							</tr>
						</table>
    					<input type="hidden" id="gameselect" name="gameselect" value="<?=$strGameID ?>" />
                		<input type="hidden" id="versionselect" name="versionselect" value="<?=$strVersionID ?>" />
    				</div>
    				<div>
    	            	<input type="submit" />
    				</div>
				</form>
		<?php 
		         
		     }
		?>
	</body>
</html>