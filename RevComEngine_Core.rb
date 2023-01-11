# RevComEngine_Core.rb / BGMRPGM_Core.rb - RPG Maker Plugin Engine
#
# MIT License
#
# Copyright (c) 2023 RevComGaming
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module BGMRPGM_Core
     
     private 

          @hWindow = nil                 # Handle to Game Window
          @w32Keys = Win32API.new('user32', 'GetKeyState', 'I', 'I')
                                         # Gatherer of Information on Key Presses
          @w32Mouse = Win32API.new("user32", "GetAsyncKeyState", 'I', 'I')
                                         # Gatherer of Information on Mouse and Keyboard Presses     
          @w32Cursor = Win32API.new('user32', 'GetCursorPos', 'P', 'I')
                                         # Gatherer of Information on Mouse Cursor Position
          @w32Screen = Win32API.new('user32', 'ScreenToClient', 'LP', 'I')
                                         # Gatherer of Information on Screen Information
          @w32AppWindowInfo = Win32API.new('user32', 'GetClientRect', 'LP', 'I')
                                         # Gatherer of Information on Game Window
          @hhSettings = {}               # Game Settings
          @hhImages = {}                 # Game Images
          @hhBGMRPGMData = {"SETTINGS" => {},
                            "IMAGES" => {},
                            "DOWNLOADER" => {"VERSION" => 0.0},
                            "APP_DATA" => {"MOBILE_SERVICES" => []},
                            "USER_DATA" => {"CONTACTS" => []}}    
                                        # Game System Data
          @strDataFilePath = "Data/BGMRPGMData.rvdata2"
                                        # Data File Path
          @ahHashUpdates = []           # List of Hashs to Update
          @hKeyList = {}                # List of Key Values
          @hBarList = {}                # List of Bar Values
          @hSpecialChars = {1 => "!", 2 => "@", 3 => "#", 4 => "$", 5 => "%", 
                            6 => "^", 7 => "&", 8 => "*", 9 => "(", 0 => ")" }
                                        # List of Special Characters for Text Values
          @hhInterfaceList = {}         # List of Interface Boxes
          @strInterfaceFocusDesign = "" # Selected Interface Designation for Input Focus
          @strInputFocusDesign = ""     # Selected Input Designation for Focus
          @haButtonInList = {}          # List of Buttons That Have Had Mouseover Events
          @hhTimers = {}                # List of Timeout and Continous Timers
          @aahMapFuncList = []          # List of Map Values for Running Events
          @nMapIDSelect = nil           # Currently Selected Map ID
          @tmInputLast = 0              # Last Time Input was Polled
          @fInputPauseDefaultSec = 0.175  
                                        # Default Time Between Input Polling
          @fInputPauseLimitSec = @fInputPauseDefaultSec
                                        # Time Between Input Polling
          @strLastInputLetter = ""      # Last Letter Inputted
          @boolUseShiftKeyUpcase = false# Indicator to Shift Key to Upcase Key Input
          @spMouse = nil                # Mouse Sprite
          @anMouseOffset = [0, 0, 100000, 0]      
                                        # Mouse Offset Position
          @ahDownloads = []             # List of Information on File Downloads
          @thdDownload = nil            # Thread for Downloads
          @boolLoggedIn = false         # Indicator That User is Logged In
          @boolInSessionGroup = false   # Indicator That User is in Session Group
          @strUserName = ""             # Username When Logged In
          @ahInviteUsernames = []        # List of Invite Usernames
          @mtxLock = nil                # Lock for Thread          
          
          def self.FuncExecute(hFuncInfo)
           
               if hFuncInfo && hFuncInfo["OBJECT"] 
           
                    if hFuncInfo["OBJECT"].respond_to?(hFuncInfo["METHOD"], true) == true
               
                         if hFuncInfo["VALUE"] && hFuncInfo["OBJECT"].method(hFuncInfo["METHOD"]).parameters.length > 0
           
                              hFuncInfo["OBJECT"].method(hFuncInfo["METHOD"]).call(hFuncInfo["VALUE"])
                                   
                         else 
                              
                              hFuncInfo["OBJECT"].method(hFuncInfo["METHOD"]).call()
                         end
                    else
                         
                         Log("Input send calling method, '" + hFuncInfo["METHOD"] + "', failed.")
                    end
               else
                      
                    Log("Input send calling method, no information send.")
               end
          end
          
          def self.DownloadVersion(fVersion)
               
               @hhBGMRPGMData["DOWNLOADER"]["VERSION"] = fVersion
               SaveGameData()
          end
          
          def self.UserCreateStatus(mxIsSuccessful, strRetMsg = "")
               
               if mxIsSuccessful == false || mxIsSuccessful == "false"
                    
                    UserInfoSubmitBtnFuncSetup()
               end
               
               UserInfoLoginBtnFuncSetup()

               if InterfaceTextSet("REVCOM-USER-PANEL", 
                                   "REVCOM-USER-STATUS-TEXT",
                                   "Status: " + strRetMsg) == false  
               
                    Log("Text field, 'REVCOM-USER-STATUS-TEXT', could not be found for returned success or failure of submission status.", true)
               end
          end
          
          def self.LoginConfirm(mxIsSuccessful, strSetUserName, strRetMsg = "")
               
               if mxIsSuccessful == true || mxIsSuccessful == "true"
                    
                    @boolLoggedIn = true
                    @strUserName = strSetUserName
                    
                    if strRetMsg == ""
                         
                         strRetMsg = "Login successful."
                    end
               else
                    
                    @boolLoggedIn = false
                    
                    if strRetMsg == ""
                         
                         strRetMsg = "Login failed."
                    end
                    
                    UserLoginSubmitBtnFuncSetup()
                    UserLoginCreateBtnFuncSetup()
               end
               
               if InterfaceTextSet("REVCOM-USERLOGIN-PANEL", 
                                   "REVCOM-USERLOGIN-STATUS-TEXT",
                                   "Status: " + strRetMsg) == false  
               
                    Log("Text field, 'REVCOM-USERLOGIN-STATUS-TEXT', could not be found for returned submission status.", true)
               end
          end
          
          def self.SetMobileService(ahMServiceInfo)
               
               @hhBGMRPGMData["APP_DATA"]["MOBILE_SERVICES"] = ahMServiceInfo
               SaveGameData()
          end
          
          def self.BtnInEvent(btnSelect)
               
               btnSelect.SetWindowBackColor(3)
          end
                              
          def self.BtnOutEvent(btnSelect)
               
               btnSelect.SetWindowBackColor()
          end
                    
          def self.BtnDisableEvent(btnSelect)
               
               btnSelect.SetWindowBackColor(4)
          end
                    
          def self.UserInfoListBtnSetup(btnList)

               strPanelName = "REVCOM-USER-MOBSERV-PANEL"   
                                    # Moble Service Panel's Name
               nWidth = 90          # Button Width
               nHeight = 45         # Button Height
               nFontSize = 18       # Button Text Font Size
#               pnlMain              # Main Panel
#               strListNum = ""      # List Number Being Created for Buttons Grouped by 4s
#               inpInteract = nil    # Selected Button
                                                
               btnList.ClearFuncs()
                    
               if !InterfaceGet(strPanelName) 
                    
                    if (pnlMain = InterfaceAdd(strPanelName, 
                                               Graphics.width / 2 - 200, 
                                               Graphics.height / 2 - 200, 
                                               nWidth * 4 + 10, 
                                               nHeight * (@hhBGMRPGMData["APP_DATA"]["MOBILE_SERVICES"].length / 4).floor() + 10))
     
                         @hhBGMRPGMData["APP_DATA"]["MOBILE_SERVICES"].each_with_index { |hMServiceInfo, nIndex|
                              
                              strListNum = (nIndex / 4).floor().to_s()
     
                              if pnlMain.CheckCompExists("REVCOM-USER-MSERVICE-LIST" + strListNum) == false
     
                                   if InterfaceListAdd(strPanelName,
                                                       "REVCOM-USER-MSERVICE-LIST" + strListNum,
                                                       5,
                                                       nHeight * strListNum.to_i() + 5,
                                                       nWidth,
                                                       nHeight) == false
               
                                        Log("List field, 'REVCOM-USER-MSERVICE-LIST" + strListNum + "', could not be created.", true)
                                   end
                              end
                              
                              if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                                   "REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s(), 
                                                                   0, 
                                                                   0, 
                                                                   nWidth,
                                                                   nHeight,
                                                                   hMServiceInfo["NAME"]))
                                           
                                   inpInteract.SetFontSize(nFontSize)
                                   
                                   if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
               
                                        Log("Button, 'REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s() + 
                                            "', mouseover event could not be setup.", true)   
                                   end
                                   
                                   if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
               
                                        Log("Button, 'REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s() + 
                                            "', mouseout event could not be setup.", true) 
                                   end
                                   
                                   if inpInteract.SetMouseClickFuncCall(self, "UserInfoListBtnClickEvent") == false
               
                                        Log("Button, 'REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s() + 
                                            "', mouse click event could not be setup.", true) 
                                   end
                                   
                                   if InterfaceListItemAdd(strPanelName, 
                                                           "REVCOM-USER-MSERVICE-LIST" + strListNum,
                                                           "REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s()) == false
     
                                        Log("Button, 'REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s() + 
                                            "' could not be added to list, 'REVCOM-USER-MSERVICE-LIST" + strListNum + "'.", true) 
                                   end
                              else
                                   
                                   Log("Button, 'REVCOM-USER-MSERVICE-BTN" + hMServiceInfo["ID"].to_s() + "', could not be created.", true)   
                              end
                         }
                    else
                         
                         Log("Panel, '" + strPanelName + "', could not be found for setting up mobile service buttons.", true) 
                    end
               end
          end

          def self.UserInfoSubmitBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-USER-PANEL",
                                                   "REVCOM-USER-SUBMIT-BTN")))
                                                   
                    BtnOutEvent(btnSubmit)
               
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false

                         Log("Button, 'REVCOM-USER-SUBMIT-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false

                         Log("Button, 'REVCOM-USER-SUBMIT-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "UserInfoSubmitBtnClickEvent") == false

                         Log("Button, 'REVCOM-USER-SUBMIT-BTN', mouse click event could not be setup.", true) 
                    end
               else
                
                    Log("Button, 'REVCOM-USER-SUBMIT-BTN', was not sent or could not be found setup events.", true)
               end
          end

          def self.UserInfoLoginBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-USER-PANEL",
                                                   "REVCOM-USER-LOGIN-BTN")))
                                                   
                    BtnOutEvent(btnSubmit)
               
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-USER-LOGIN-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-USER-LOGIN-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "UserInfoLoginBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-USER-LOGIN-BTN', mouse click event could not be setup.", true) 
                    end
               else
                
                    Log("Button, 'REVCOM-USER-LOGIN-BTN', was not sent or could not be found setup events.", true)
               end
          end
          
          def self.SessionGroupStartBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-SESSIONGROUP-PANEL",
                                                   "REVCOM-SESSIONGROUP-START-BTN")))
                                                   
                    BtnOutEvent(btnSubmit)
          
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-START-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-START-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "SessionGroupStartBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-START-BTN', mouse click event could not be setup.", true) 
                    end

               else
                
                    Log("Button, 'REVCOM-SESSIONGROUP-START-BTN', was not sent or could not be found setup events.", true)
               end
          end

          def self.SessionGroupInviteListBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-SESSIONGROUP-PANEL",
                                                   "REVCOM-SESSIONGROUP-INVITE-BTNLIST")))
                                                   
                    BtnOutEvent(btnSubmit)
          
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "SessionGroupInviteBtnListClickEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST', mouse click event could not be setup.", true) 
                    end
                    
               else
                
                    Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST', was not sent or could not be found setup events.", true)
               end
          end
          
          def self.SessionGroupInviteBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-SESSIONGROUP-PANEL",
                                                   "REVCOM-SESSIONGROUP-INVITE-BTN")))
                                                   
                    BtnOutEvent(btnSubmit)
          
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "SessionGroupInviteBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN', mouse click event could not be setup.", true) 
                    end
                    
               else
                
                    Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN', was not sent or could not be found setup events.", true)
               end
          end

          def self.SessionGroupInviteListBtnClickEvent(btnSelect)
               
               btnSelect.ClearFuncs()
          
               if InputClear("REVCOM-SESSIONGROUP-PANEL",
                             "REVCOM-SESSIONGROUP-INVITE-INPUT") == true &&
                  InputWrite(btnSelect.GetText(),
                             "REVCOM-SESSIONGROUP-PANEL",
                             "REVCOM-SESSIONGROUP-INVITE-INPUT") == true

                    if InterfaceGet("REVCOM-SESSIONGROUP-INVITE-PANEL") &&
                       InterfaceRemove("REVCOM-SESSIONGROUP-INVITE-PANEL") == false
                     
                         Log("Panel, 'REVCOM-SESSIONGROUP-INVITE-PANEL', could not be found to be removed.", true)
                    end
                    
                    SessionGroupInviteListBtnFuncSetup()
          
                    MouseOutSend("REVCOM-SESSIONGROUP-PANEL",
                                 "REVCOM-SESSIONGROUP-INVITE-BTNLIST")
               else
                    
                    Log("Input, 'REVCOM-SESSIONGROUP-INVITE-INPUT', could not be found to be set.", true) 
               end
          end
          
          def self.UserInfoMServiceBtnListFuncSetup

               ButtonMouseInSetSendFunc("REVCOM-USER-PANEL",
                                        "REVCOM-USER-MSERVICE-BTNLIST",
                                        self,
                                        "BtnInEvent")

               ButtonMouseOutSetSendFunc("REVCOM-USER-PANEL",
                                         "REVCOM-USER-MSERVICE-BTNLIST",
                                         self,
                                         "BtnOutEvent")

               ButtonMouseClickSetSendFunc("REVCOM-USER-PANEL",
                                           "REVCOM-USER-MSERVICE-BTNLIST",
                                           self,
                                           "UserInfoListBtnSetup")
          end
                              
          def self.UserInfoListBtnClickEvent(btnSelect)
                                   
               strMobServText = btnSelect.GetText()    
                                    # Mobile Service Text
               
               btnSelect.ClearFuncs()

               if (InterfaceTextSet("REVCOM-USER-PANEL",
                                    "REVCOM-USER-MSERVICE-TEXT",
                                    "Mobile Service: " + strMobServText) == true)
                    
                    @hhBGMRPGMData["APP_DATA"]["MOBILE_SERVICES"].each { |hMobServInfo|
                         
                         if strMobServText == hMobServInfo["NAME"]

                              if (InputClear("REVCOM-USER-PANEL",
                                             "REVCOM-USER-MSERVICE-INPUT") == false || 
                                  InputWrite(hMobServInfo["ID"].to_s(),
                                             "REVCOM-USER-PANEL",
                                             "REVCOM-USER-MSERVICE-INPUT") == false)
                               
                                   Log("Input, 'REVCOM-USER-MSERVICE-INPUT', could not be set with mobile ID.", true)
                              end

                              break
                         end
                    }
                         
                    if InterfaceGet("REVCOM-USER-MOBSERV-PANEL") &&
                       InterfaceRemove("REVCOM-USER-MOBSERV-PANEL") == false
                     
                         Log("Panel, 'REVCOM-USER-MOBSERV-PANEL', could not be found to be removed.", true)
                    end
                    
                    UserInfoMServiceBtnListFuncSetup()
     
                    MouseOutSend("REVCOM-USER-PANEL",
                                 "REVCOM-USER-MSERVICE-BTNLIST")
               else
                    
                    Log("Text, 'REVCOM-USER-MSERVICE-TEXT', could not be found to be set.", true) 
               end
          end
                    
          def self.UserInfoSubmitBtnClickEvent(btnSubmit)
               
               strPanelName = "REVCOM-USER-PANEL"
                                    # Panel Name
               nFontSize = 18       # Standard Front Size
               strSetUserName = ""  # Username Input
               strPassword = ""     # Password Input
               strPhoneNum = ""     # Phone Number Input
               strEmail = ""        # E-mail Address Input
               strMobServID = ""    # Mobile Service ID
               strStatusMsg = ""    # Status Message
               boolNoError = true   # Indicator That No Error Has                    
#               nMsgID = RevCommProcessor.GetUniqueID()     
                                    # Messsage ID for Sending to Data Process for User Creation Information
                    
               BtnOutEvent(btnSubmit)
               btnSubmit.ClearFuncs()
               
               if (strSetUserName = InputRead(strPanelName, "REVCOM-USER-USERNAME-INPUT", false)) != "" ||
                  (@boolLoggedIn == true && (strSetUserName = @strUserName) != "")
                         
                    if (strPassword = InputRead(strPanelName, "REVCOM-USER-PASSWORD-INPUT", false)) != ""
                         
                         if strPassword == InputRead(strPanelName, "REVCOM-USER-PASSCONFIRM-INPUT", false)
                                          
                              if InterfaceInputGet(strPanelName, "REVCOM-USER-PHONENUM-INPUT") &&
                                 (((strPhoneNum = InputRead(strPanelName, "REVCOM-USER-PHONENUM-INPUT", false)) == "" ||
                                  (strMobServID = InputRead(strPanelName, "REVCOM-USER-MSERVICE-INPUT", false)) == "") &&
                                 InterfaceInputGet(strPanelName, "REVCOM-USER-PHONEREQ-INPUT"))
                                        
                                   strStatusMsg = "Phone number and mobile service must be set."
                                   boolNoError = false
                              end   
                                               
                              if boolNoError == true && 
                                 InterfaceInputGet(strPanelName, "REVCOM-USER-EMAIL-INPUT") &&
                                 ((strEmail = InputRead(strPanelName, "REVCOM-USER-EMAIL-INPUT", false)) == "" &&
                                  InterfaceInputGet(strPanelName, "REVCOM-USER-EMAILREQ-INPUT"))
                                      
                                   strStatusMsg = "E-mail address must be set."
                                   boolNoError = false
                              end 
                         else
                            
                              strStatusMsg = "Passwords do not match."
                              boolNoError = false
                         end 
                    else 
                       
                         strStatusMsg = "Password must be set."
                         boolNoError = false     
                    end   
               else
                    
                    strStatusMsg = "Username must be set."
                    boolNoError = false
               end  
               
               if boolNoError == true
                    
                    nMsgID = RevCommProcessor.GetUniqueID()     
                    
                    RevCommProcessor.AutoRetProcessCmd(true)
                    RevCommProcessor.AutoRetEndTrans(true)
                    RevCommProcessor.StartDataProcess(nMsgID, 'user_create_update')
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'username', strSetUserName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'password', strPassword)
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'phonenum', strPhoneNum)
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'mobservID', strMobServID)
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'email', strEmail)
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'isupdate', @boolLoggedIn)
                    
                    if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == true
                         
                         BtnDisableEvent(btnSubmit)
                         
                         SetInputButtonBackColor(strPanelName, "REVCOM-USER-LOGIN-BTN", 4)
                         ButtonRemoveSendFuncs(strPanelName, "REVCOM-USER-LOGIN-BTN")
                    else 
                         
                         UserInfoSubmitBtnFuncSetup(btnSubmit)
                         strStatusMsg = "Error occurred, data not sent."
                    end                         
               else
                    
                    UserInfoSubmitBtnFuncSetup(btnSubmit)
               end
               
               if InterfaceTextSet(strPanelName, 
                                   "REVCOM-USER-STATUS-TEXT",
                                   "Status: " + strStatusMsg) == false  
               
                    Log("Text field, 'REVCOM-USER-STATUS-TEXT', could not be found for submission status.", true)
               end
          end
          
          def self.SessionGroupStartBtnClickEvent(btnSelect = nil)

               strPanelName = "REVCOM-SESSIONGROUP-PANEL" 
                                    # Panel Name     
               nMsgID = RevCommProcessor.GetUniqueID() 
                                    # Messsage ID for Sending to Data Process for User Creation Information    
               
               RevCommProcessor.AutoRetProcessCmd(true)
               RevCommProcessor.AutoRetEndTrans(true)
               RevCommProcessor.StartDataProcess(nMsgID, 'session_group_start')
               RevCommProcessor.AddDataProcessParams(nMsgID, 'username', @strUserName) 
               
               if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == true
                    
                    SetInputButtonBackColor(strPanelName, "REVCOM-SESSIONGROUP-START-BTN", 4)
                    ButtonRemoveSendFuncs(strPanelName, "REVCOM-SESSIONGROUP-START-BTN")
               elsif InterfaceTextSet(strPanelName,
                                      "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                      "Status: Error occurred, data not sent.") == false
     
                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be updated for session group start error.", true)
               end 
          end
          
          def self.SessionGroupInviteBtnClickEvent(btnSelect = nil)

               strPanelName = "REVCOM-SESSIONGROUP-PANEL" 
                                    # Panel Name     
               nMsgID = RevCommProcessor.GetUniqueID() 
                                    # Messsage ID for Sending to Data Process for User Creation Information    
               strInviteName = InputRead(strPanelName,
                                         "REVCOM-SESSIONGROUP-INVITE-INPUT")
                                    # Name of User Being Invited
               strTimeLimit = InputRead(strPanelName,
                                        "REVCOM-SESSIONGROUP-TIMELIMIT-INPUT", 
                                        false)
                                   # Default Time Limit for Invites
               
               if strInviteName != '' && @strUserName != strInviteName
                    
                    if strTimeLimit == ''
                         
                         strTimeLimit = '0'
                    end
                                      
                    RevCommProcessor.AutoRetProcessCmd(true)
                    RevCommProcessor.AutoRetEndTrans(true)
                    RevCommProcessor.StartDataProcess(nMsgID, 'session_group_invite')
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'username', @strUserName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'invitename', strInviteName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'timelimit', strTimeLimit) 
                    
                    if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == true
                         
                         SetInputButtonBackColor(strPanelName, "REVCOM-SESSIONGROUP-INVITE-BTN", 4)
                         ButtonRemoveSendFuncs(strPanelName, "REVCOM-SESSIONGROUP-INVITE-BTN")
                    elsif InterfaceTextSet(strPanelName,
                                           "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                           "Status: Error occurred, data not sent.") == false
          
                         Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be updated with invite user error.", true)
                    end
               elsif InterfaceTextSet(strPanelName,
                                      "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                      "Status: Must enter username of person being invited.") == false

                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be updated for missing invite user issue.", true)
               end
          end
          
          def self.SessionGroupInviteBtnListClickEvent(btnSelect = nil)
               
               strPanelName = "REVCOM-SESSIONGROUP-INVITE-PANEL"   
                                    # Session Group Invite User Panel's Name
               nWidth = 90          # Button Width
               nHeight = 45         # Button Height
               nFontSize = 18       # Button Text Font Size
               nContacts = @hhBGMRPGMData["USER_DATA"]["CONTACTS"].length
                                    # Count of Contact User Name
#               pnlMain              # Main Panel
#               strListNum = ""      # List Number Being Created for Buttons Grouped by 4s
#               inpInteract = nil    # Selected Button
                    
               if nContacts > 0    
                                            
                    btnSelect.ClearFuncs()
                         
                    if !InterfaceGet(strPanelName) 
                         
                         if (pnlMain = InterfaceAdd(strPanelName, 
                                                    Graphics.width / 2 - 200, 
                                                    Graphics.height / 2 - 200, 
                                                    nWidth * 4 + 10, 
                                                    nHeight * (nContacts / 4).floor() + 10))
          
                              @hhBGMRPGMData["USER_DATA"]["CONTACTS"].each_with_index { |strInviteName, nIndex|
                                   
                                   strListNum = (nIndex / 4).floor().to_s()
          
                                   if pnlMain.CheckCompExists("REVCOM-SESSIONGROUP-INVITE-BTNLIST" + strListNum) == false
          
                                        if InterfaceListAdd(strPanelName,
                                                            "REVCOM-SESSIONGROUP-INVITE-LIST" + strListNum,
                                                            5,
                                                            nHeight * strListNum.to_i() + 5,
                                                            nWidth,
                                                            nHeight) == false
                    
                                             Log("List field, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST" + strListNum + "', could not be created.", true)
                                        end
                                   end
                                   
                                   if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                                        "REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s(), 
                                                                        0, 
                                                                        0, 
                                                                        nWidth,
                                                                        nHeight,
                                                                        strInviteName))
                                                
                                        inpInteract.SetFontSize(nFontSize)
                                        
                                        if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
                    
                                             Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s() + 
                                                 "', mouseover event could not be setup.", true)   
                                        end
                                        
                                        if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
                    
                                             Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s() + 
                                                 "', mouseout event could not be setup.", true) 
                                        end
                                        
                                        if inpInteract.SetMouseClickFuncCall(self, "SessionGroupInviteListBtnClickEvent") == false
                    
                                             Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s() + 
                                                 "', mouse click event could not be setup.", true) 
                                        end
                                        
                                        if InterfaceListItemAdd(strPanelName, 
                                                                "REVCOM-SESSIONGROUP-INVITE-LIST" + strListNum,
                                                                "REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s()) == false
          
                                             Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s() + 
                                                 "' could not be added to list, 'REVCOM-SESSIONGROUP-INVITE-LIST" + strListNum + "'.", true) 
                                        end
                                   else
                                        
                                        Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN" + nIndex.to_s() + "', could not be created.", true)   
                                   end
                              }
                         else
                              
                              Log("Panel, '" + strPanelName + "', could not be found for setting up invite user list buttons.", true) 
                         end
                    end
               elsif InterfaceTextSet("REVCOM-SESSIONGROUP-PANEL",
                                      "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                      "Status: No contacts exists for invites.") == false

                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be updated for no contacts issue.", true)
               end
          end
          
          def self.SessionGroupCheck
               
               nMsgID = RevCommProcessor.GetUniqueID() 
                                    # Messsage ID for Sending to Data Process   
                                      
               RevCommProcessor.AutoRetProcessCmd(true)
               RevCommProcessor.AutoRetEndTrans(true)
               RevCommProcessor.StartDataProcess(nMsgID, 'session_group_check')
               RevCommProcessor.AddDataProcessParams(nMsgID, 'username', @strUserName) 
               
               if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == false

                    Log("Doing session group check failed.", true)
               end
          end

          def self.SessionGroupInviteSetup(strInviteUserName,
                                           strInviteMsg,
                                           nXPos = Graphics.width / 2 - 200, 
                                           nYPos = Graphics.height / 2 - 200)
               
               strPanelName = "REVCOM-INVITERECEIVE-PANEL" 
                                    # Panel Name     
#               pnlMain = nil        # Main Panel  
               nPanelWidth = 400    # Width of Panel
               nPanelHeight = 120   # Height of Panel  
               nTextXOffset = 10    # X-Axis Offset of Text
               nTextYTop = 30       # Starting Y-Axis Position of Text
               nTextYOffset = 40    # Starting Y-Axis Offset of Text
               nInpWidth = 175      # Width of Input
               nInpHeight = 40      # Height of Input
               nInpXOffset = 200    # X-Axis Offset of Input
               nInpYTop = 55        # Starting Y-Axis Position of Input
               nInpYOffset = 15     # Starting Y-Axis Offset of Input
               inpInteract = nil    # Interactive Object       
               nFontSize = 14       # Stardard Font Size    
               
               pnlMain = InterfaceAdd(strPanelName, 
                                      nXPos, 
                                      nYPos, 
                                      nPanelWidth, 
                                      nPanelHeight) 
               if pnlMain
               
                    pnlMain.SetFontSize(nFontSize)
               else
                          
                    Log("Panel, '" + strPanelName + "', could not be created.", true)
               end
                                     
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-INVITERECEIVE-TITLE-TEXT",
                                   "Invite Notice",
                                   nPanelWidth / 2 - 35,
                                   10) == false
                          
                    Log("Text field, 'REVCOM-INVITERECEIVE-TITLE-TEXT', could not be created.", true)
               end
                                     
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-INVITERECEIVE-INFO-TEXT",
                                   strInviteMsg,
                                   nTextXOffset,
                                   nTextYTop) == false
                          
                    Log("Text field, 'REVCOM-INVITERECEIVE-INFO-TEXT', could not be created.", true)
               end   
               
               if (inpInteract = InterfaceButtonAdd(strPanelName,  
                                                    "REVCOM-INVITERECEIVE-ACCEPT-BTN", 
                                                    nPanelWidth / 2 - 65,
                                                    nInpYTop + nInpYOffset,
                                                    65, 
                                                    45,
                                                    "ACCEPT"))
                           
                    inpInteract.SetFontSize(nFontSize)

                    if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-ACCEPT-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-ACCEPT-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseClickFuncCall(self, "SessionGroupInviteAcceptBtnClickEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-ACCEPT-BTN', mouse click event could not be setup.", true) 
                    end
               else
                   
                    Log("Button, 'REVCOM-INVITERECEIVE-ACCEPT-BTN', could not be created.", true)
               end  
               
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-INVITERECEIVE-REJECT-BTN", 
                                                    nPanelWidth / 2,
                                                    nInpYTop + nInpYOffset,
                                                    65, 
                                                    45,
                                                    "REJECT"))
                      
                    inpInteract.SetFontSize(nFontSize)
               
                    if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-REJECT-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-REJECT-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseClickFuncCall(self, "SessionGroupInviteRejectBtnClickEvent") == false
                    
                        Log("Button, 'REVCOM-INVITERECEIVE-REJECT-BTN', mouse click event could not be setup.", true) 
                    end
               else
               
                    Log("Button, 'REVCOM-INVITERECEIVE-REJECT-BTN', could not be created.", true)   
               end   

               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-INVITERECEIVE-USERNAME-INPUT",
                                                   0,
                                                   0,
                                                   0,
                                                   0))
                    
                    inpInteract.Show(false) 
                    InputWrite(strInviteUserName, "REVCOM-INVITERECEIVE-PANEL", "REVCOM-INVITERECEIVE-USERNAME-INPUT")
               else

                    Log("Input field, 'REVCOM-INVITERECEIVE-USERNAME-INPUT', could not be created.", true) 
               end 

          end
                         
          def self.UserInfoCloseBtnClickEvent(btnSelect = nil)
               
               if InterfaceRemove("REVCOM-USER-PANEL") == false
               
                    Log("Panel, 'REVCOM-USER-PANEL', could not be found for removal.", true)
               end
               
               if InterfaceGet("REVCOM-USER-MOBSERV-PANEL") &&
                  InterfaceRemove("REVCOM-USER-MOBSERV-PANEL") == false

                    Log("Panel, 'REVCOM-USER-MOBSERV-PANEL', could not be found for removal.", true)
               end
          end
          
          def self.UserInfoLoginBtnClickEvent(btnSelect = nil)
               
               UserInfoCloseBtnClickEvent()
               
               LoginCreateSetup()
          end

          def self.UserLoginSubmitBtnFuncSetup(btnSubmit = nil)
          
               if (btnSubmit ||
                   (btnSubmit = InterfaceButtonGet("REVCOM-USERLOGIN-PANEL",
                                                   "REVCOM-USERLOGIN-SUBMIT-BTN")))
                                                   
                    BtnOutEvent(btnSubmit)
               
                    if btnSubmit.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-SUBMIT-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-SUBMIT-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnSubmit.SetMouseClickFuncCall(self, "UserLoginSubmitBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-SUBMIT-BTN', mouse click event could not be setup.", true) 
                    end
               else
                
                    Log("Button, 'REVCOM-USERLOGIN-SUBMIT-BTN', was not sent or could not be found setup events.", true)
               end
          end

          def self.UserLoginCreateBtnFuncSetup(btnLogin = nil)
          
               if (btnLogin ||
                   (btnLogin = InterfaceButtonGet("REVCOM-USERLOGIN-PANEL",
                                                  "REVCOM-USERLOGIN-CREATE-BTN")))
                                                   
                    BtnOutEvent(btnLogin)
               
                    if btnLogin.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CREATE-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if btnLogin.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CREATE-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if btnLogin.SetMouseClickFuncCall(self, "UserLoginCreateBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CREATE-BTN', mouse click event could not be setup.", true) 
                    end
               else
                
                    Log("Button, 'REVCOM-USERLOGIN-CREATE-BTN', was not sent or could not be found setup events.", true)
               end
          end
          
          def self.UserLoginCreateBtnClickEvent(btnSelect = nil)
               
               UserLoginCloseBtnClickEvent()
               
               UserInfoSetup()
          end
          
          def self.UserLoginSubmitBtnClickEvent(btnSubmit)
               
               strPanelName = "REVCOM-USERLOGIN-PANEL"
                                    # Panel Name
               nFontSize = 18       # Standard Front Size
               strSetUserName = ""  # Username Input
               strPassword = ""     # Password Input
               strStatusMsg = ""    # Status Message
               boolNoError = true   # Indicator That No Error Has  
               btnLogin = InterfaceButtonGet("REVCOM-USERLOGIN-PANEL",
                                             "REVCOM-USERLOGIN-CREATE-BTN")  
                                    # Login Button tp Disable
#               nMsgID = RevCommProcessor.GetUniqueID()     
                                    # Messsage ID for Sending to Data Process for User Login Information
                    
               BtnOutEvent(btnSubmit)
               btnSubmit.ClearFuncs()

               BtnOutEvent(btnLogin)
               btnLogin.ClearFuncs()
               
               if (strSetUserName = InputRead(strPanelName, "REVCOM-USERLOGIN-USERNAME-INPUT", false)) != ""
                         
                    if (strPassword = InputRead(strPanelName, "REVCOM-USERLOGIN-PASSWORD-INPUT", false)) == ""
                       
                         strStatusMsg = "Password must be set."
                         boolNoError = false     
                    end   
               else
                    
                    strStatusMsg = "Username must be set."
                    boolNoError = false
               end  
               
               if boolNoError == true
                    
                    nMsgID = RevCommProcessor.GetUniqueID()     
                    
                    RevCommProcessor.AutoRetProcessCmd(true)
                    RevCommProcessor.AutoRetEndTrans(true)
                    RevCommProcessor.StartDataProcess(nMsgID, 'user_login')
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'username', strSetUserName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'password', strPassword)
                    
                    if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == true
                         
                         BtnDisableEvent(btnSubmit) 
                         BtnDisableEvent(btnLogin)
                    else 
                         
                         UserLoginSubmitBtnFuncSetup(btnSubmit)
                         UserLoginCreateBtnFuncSetup(btnLogin)
                         strStatusMsg = "Error occurred, data not sent"
                    end                         
               else
                    
                    UserLoginSubmitBtnFuncSetup(btnSubmit)
                    UserLoginCreateBtnFuncSetup(btnLogin)
               end
               
               if InterfaceTextSet(strPanelName, 
                                   "REVCOM-USERLOGIN-STATUS-TEXT",
                                   "Status: " + strStatusMsg) == false  
               
                    Log("Text field, 'REVCOM-USERLOGIN-STATUS-TEXT', could not be found for submission status.", true)
               end
          end
                    
          def self.UserLoginCloseBtnClickEvent(btnSelect = nil)
               
               if InterfaceRemove("REVCOM-USERLOGIN-PANEL") == false
               
                    Log("Panel, 'REVCOM-USERLOGIN-PANEL', could not be found for removal.", true)
               end
          end
          
          def self.SessionGroupCloseBtnClickEvent(btnSelect = nil)
               
               if InterfaceRemove("REVCOM-SESSIONGROUP-PANEL") == false
               
                    Log("Panel, 'REVCOM-SESSIONGROUP-PANEL', could not be found for removal.", true)
               end
               
               if InterfaceGet("REVCOM-SESSIONGROUP-INVITE-PANEL") &&
                  InterfaceRemove("REVCOM-SESSIONGROUP-INVITE-PANEL") == false

                    Log("Panel, 'REVCOM-SESSIONGROUP-INVITE-PANEL', could not be found for removal.", true)
               end
          end

          def self.SessionGroupInviteAcceptBtnClickEvent(btnSelect)
               
               SessionGroupInviteResponse(InputRead("REVCOM-INVITERECEIVE-PANEL", "REVCOM-INVITERECEIVE-USERNAME-INPUT"), true) 
          end

          def self.SessionGroupInviteRejectBtnClickEvent(btnSelect)
               
               SessionGroupInviteResponse(InputRead("REVCOM-INVITERECEIVE-PANEL", "REVCOM-INVITERECEIVE-USERNAME-INPUT"), false) 
          end

          def self.SessionGroupInviteResponse(strSenderName, boolAccepted)
               
               nMsgID = RevCommProcessor.GetUniqueID()     
               strButtonAction = "REJECT"
          #               hNextInvite = @ahInviteUsernames.pop()
                              
               if InterfaceGet("REVCOM-INVITERECEIVE-PANEL") &&
                  InterfaceRemove("REVCOM-INVITERECEIVE-PANEL") == false
                                    
                    BtnDisableEvent(btnSelect)
                    btnSelect.ClearFuncs()
                    
                    if boolAccepted == true

                         strButtonAction = "ACCEPT"
                    end
                    
                    ButtonRemoveSendFuncs("REVCOM-INVITERECEIVE-PANEL", "REVCOM-INVITERECEIVE-" + strButtonAction + "-BTN")
                    BtnDisableEvent(InterfaceButtonGet("REVCOM-INVITERECEIVE-PANEL", "REVCOM-INVITERECEIVE-" + strButtonAction + "-BTN"))
                    Log("During sending session group invite " + strButtonAction.downcase() + ", removing panel failed.", true)
               end
               
               if boolAccepted.is_a?(TrueClass) || boolAccepted.is_a?(FalseClass)
                    
                    RevCommProcessor.AutoRetProcessCmd(true)
                    RevCommProcessor.AutoRetEndTrans(true)
                    RevCommProcessor.StartDataProcess(nMsgID, 'session_group_invite_finish')
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'username', strSenderName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'invitename', @strUserName) 
                    RevCommProcessor.AddDataProcessParams(nMsgID, 'accept', boolAccepted) 
                    
                    if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == true
                         
                         if @ahInviteUsernames.length() > 0
                         
                              hNextInvite = @ahInviteUsernames.pop()
                              SessionGroupInviteSetup(hNextInvite["USERNAME"], hNextInvite["MESSAGE"])
                         end
                    else 
                         
                         Log("During sending session group invite accept, send failed.", true)
                    end  
                    
                    if boolAccepted && @hhBGMRPGMData["USER_DATA"]["CONTACTS"].include?(strSenderName) == false
                         
                         @hhBGMRPGMData["USER_DATA"]["CONTACTS"].push(strSenderName)
                    end
               else
                    
                    Log("During sending session group invite accept or reject, send terminated due to 'accept' value being wrong type.", 
                        true)
               end
          end
          
          def self.SessionGroupCreateConfirm(mxIsSuccessful, strRetMsg = "")
               
               if mxIsSuccessful == true || mxIsSuccessful == "true"
                    
                    @boolInSessionGroup = true
                    SessionGroupInviteListBtnFuncSetup()
                    SessionGroupInviteBtnFuncSetup()
               else

                    @boolInSessionGroup = false
                    SessionGroupStartBtnFuncSetup()
               end
               
               if InterfaceTextSet("REVCOM-SESSIONGROUP-PANEL",
                                   "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                   "Status: " + strRetMsg) == false
               
                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be created for session group creation.", true)
               end 
          end
          
          def self.SessionGroupInviteConfirm(mxIsSuccessful, strRetMsg = "", strSenderName = "")
               
               if strSenderName != "" && 
                  @hhBGMRPGMData["USER_DATA"]["CONTACTS"].include?(strSenderName) == false
                       
                    @hhBGMRPGMData["USER_DATA"]["CONTACTS"].push(strSenderName)
               end
               
               SessionGroupInviteListBtnFuncSetup()
               SessionGroupInviteBtnFuncSetup()
               
               if InterfaceTextSet("REVCOM-SESSIONGROUP-PANEL",
                                   "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                   "Status: " + strRetMsg) == false
               
                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be created for session group invite confirmation.", true)
               end 
          end
          
          def self.SessionGroupInviteReceive(strRetMsg = "", strSenderName = "")
               
               if strSenderName != "" 
                    
                    if !InterfaceGet("REVCOM-INVITERECEIVE-PANEL")
                    
                         SessionGroupInviteSetup(strSenderName, strRetMsg)
                    else
                         
                         @ahInviteUsernames.push({"USERNAME" => strSenderName,
                                                  "MESSAGE" => strRetMsg})
                    end
               end
          end
          
          def self.SessionGroupInviteInform(strRetMsg = "", strSenderName = "") 
               
               SessionGroupInviteComplete(strRetMsg, strSenderName)
          end
               
          def self.SessionGroupInviteFinish(mxIsSuccessful, strRetMsg = "", strSenderName = "") 
               
               if mxIsSuccessful == true || mxIsSuccessful == "true"
                    
                    @boolInSessionGroup = true

               else

                    @boolInSessionGroup = false
               end
               
               SessionGroupInviteComplete(strRetMsg, strSenderName)
          end
               
          def self.SessionGroupInviteComplete(strRetMsg = "", 
                                              strSenderName = "",
                                              nXPos = 10, 
                                              nYPos = Graphics.height / 2 - 200)
               
               strPanelName = "REVCOM-SESSIONGROUP-INVITEEND-PANEL"   
                                    # Session Group Invite Completion User Panel's Name   
#               pnlMain = nil        # Main Panel  
               nWidth = 400         # Panel Width
               nHeight = 60        # Panel Height
                         
               if !InterfaceGet(strPanelName) 
                    
                    if (pnlMain = InterfaceAdd(strPanelName, 
                                               nXPos, 
                                               nYPos, 
                                               nWidth, 
                                               nHeight))

                         pnlMain.SetFontSize(14)

                         if InterfaceTextAdd(strPanelName,
                                             "REVCOM-SESSIONGROUP-INVITEEND-TEXT",
                                             "Status: " + strRetMsg + " User: " + strSenderName,
                                             10,
                                             10) == false
                                          
                              Log("Text field, 'REVCOM-SESSIONGROUP-INVITEEND-TEXT', could not be created.", true)  
                         end 
                         
                         SetTimer('REVCOM-INVITE-END-TIMER',
                                  self,
                                  'SessionGroupInviteEnd',
                                  5000)
                    else
                         
                         Log("Panel, '" + strPanelName + "', could not be found for setting up for invite confirmation.", true) 
                    end
               end
          end

          def self.SessionGroupInviteEnd
                              
               if InterfaceGet("REVCOM-SESSIONGROUP-INVITEEND-PANEL") &&
                  InterfaceRemove("REVCOM-SESSIONGROUP-INVITEEND-PANEL") == false
                  
                    Log("During removing session group invite confimation panel, removing panel failed.", true)
               end
          end
          
          def self.SessionGroupCheckConfirm(mxIsSuccessful)
               
               if mxIsSuccessful == true || mxIsSuccessful == "true"
                    
                    @boolInSessionGroup = true
               else

                    @boolInSessionGroup = false
               end
          end
          
     public
          
          def self.Initialize(strTitle = nil, boolMapDefaultKeys = true) 
               
               if self.const_defined?("RevCommProcessor") == true
                    
                    # TODO - Depreciate'BGMRPGMCORE' Register
                    RevCommProcessor.RegisterObject('BGMRPGMCORE', self)
                    RevCommProcessor.RegisterObject('RCECORE', self)
               end
               
               SetActiveWindow(strTitle)
               
               # Load Files
               if File.exists?(@strDataFilePath) == true
                        
                      File.open(@strDataFilePath, "rb") do |flRead|
                        
                           @hhBGMRPGMData = Marshal.load(flRead)
                           
                           if @hhBGMRPGMData["SETTINGS"] 
                           
                                @hhSettings = @hhBGMRPGMData["SETTINGS"]
                           end
                           
                           if @hhBGMRPGMData["IMAGES"] 
                           
                                @hhBGMRPGMData["IMAGES"].each{ |strImgDesign, hImgInfo|
                                
                                     SetImage(strImgDesign, 
                                              hImgInfo["SPRITESHEET"],
                                              hImgInfo["TYPE"],
                                              hImgInfo["WIDTH"],
                                              hImgInfo["HEIGHT"],
                                              hImgInfo["X-POSITION"],
                                              hImgInfo["Y-POSITION"])
                                }
                           end
                      end
               end
               
               InputMapReset()
                 
               if boolMapDefaultKeys == true
                    
                      InputMapDefaults()
               end
          end
          
          def self.Connect(strServerIPHostName, nPort = 59234)
               
               boolConnected = false# Indicator that Connection was Made                         
#               nMsgID = RevCommProcessor.GetUniqueID()     
                                    # Messsage ID for Sending to Data Process for File Information
               
               if self.const_defined?("RevCommProcessor") == true
  
                    if (boolConnected = RevCommProcessor.Connect(strServerIPHostName, nPort)) == true 
                    
                         if @thdDownload == nil
                                       
                              @thdDownload = Thread.new {
                                                                    
                                   while RevCommProcessor.IsConnected() == true do
                                                                     
                                        BGMRPGM_Core.ManageDownloads()
                                        sleep(0.1)
                                   end
                              }
                         end
                         
                         nMsgID = RevCommProcessor.GetUniqueID()     
                         
                         RevCommProcessor.AutoRetProcessCmd(true)
                         RevCommProcessor.AutoRetEndTrans(true)
                         RevCommProcessor.StartDataProcess(nMsgID, 'mobile_service_load')
                              
                         if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == false
                              
                              Log('During connecting to server, getting mobile service list failed.')
                         end    
                    end
               else
                    
                    Log('Connecting to server failed, RevCommProcessor required.')
               end
               
               return boolConnected
          end
          
          def self.IsConnected
               
               boolConnected = false# Indicator that Connection Exists
               
               if self.const_defined?("RevCommProcessor") == true
          
                    boolConnected = RevCommProcessor.IsConnected()
               end
               
               return boolConnected
          end
                    
          def self.Update
                    
               boolIsNewMap = false # Indicator That a New Map is Being Used
               
               if !@hWindow
                    
                    SetActiveWindow()
               end
            
               InputButtonProcess()
               ManageFollowers()
               ManageTimers()
               ManageInterfaceBars()
               
               if self.const_defined?("SceneManager") == true
     
                    if $game_map && @nMapIDSelect != $game_map.map_id
                         
                         boolIsNewMap = true
                         @nMapIDSelect = $game_map.map_id
                    end
                     
                    if boolIsNewMap == true && @aahMapFuncList[@nMapIDSelect]

                         @aahMapFuncList[@nMapIDSelect].delete_if { |hMapFuncInfo|

                              FuncExecute(hMapFuncInfo["EXECUTE"])
                              hMapFuncInfo["REMOVE"]
                         }
                    end
               end
               
               UpdateHashSafe(@hhInterfaceList, false).each { |strDesignSelect, hInterface|
                    
                    hInterface.DequeueEventFuncs().each { |hEventSelect|
               
                         FuncExecute(hEventSelect)
                    }
               }
          
               @ahHashUpdates.each { |hUpdates|
               
                    if hUpdates['ORIGINAL'] != hUpdates['CLONE'] && hUpdates['UPDATE'] == true
                         
                         hUpdates['ORIGINAL'].merge!(hUpdates['CLONE'])
                    end
               }
               
               @ahHashUpdates = []
          end
          
          def self.GetVersion
               
               return "2.0"
          end
          
          # Set Specified Setting
          def self.SetSetting(strSettingName, mxValue)
          
               @hhSettings[strSettingName] = mxValue
          end    
          
          # Get Specified Setting
          def self.GetSetting(strSettingName)
          
               return @hhSettings[strSettingName]
          end  
          
          # Find If Specified Setting
          def self.IsSetting(strSettingName)
                
               return @hhSettings.has_key?(strSettingName)
          end
          
          def self.IsLoggedIn
               
               return @boolLoggedIn
          end

          def self.GetUserName
               
               return @strUserName
          end
          
          def self.UserInfoSetup(nXPos = Graphics.width / 2 - 200, 
                                 nYPos = Graphics.height / 2 - 200, 
                                 boolAddPhoneNum = false,
                                 boolAddEmail = false,
                                 boolRequirePhoneNum = false,
                                 boolRequireEmail = false)

               strPanelName = "REVCOM-USER-PANEL" 
                                    # Panel Name     
#               pnlMain = nil        # Main Panel  
               strTitle = "CREATE USER" 
                                    # Panel Title
               nPanelWidth = 400    # Width of Panel
               nPanelHeight = 400   # Height of Panel  
               nTextXOffset = 15    # X-Axis Offset of Text
               nTextYTop = 55       # Starting Y-Axis Position of Text
               nTextYOffset = 40    # Starting Y-Axis Offset of Text
               nInpWidth = 175      # Width of Input
               nInpHeight = 40      # Height of Input
               nInpXOffset = 200    # X-Axis Offset of Input
               nInpYTop = 55        # Starting Y-Axis Position of Input
               nInpYOffset = 40     # Starting Y-Axis Offset of Input
               inpInteract = nil    # Interactive Object       
               nFontSize = 14       # Stardard Font Size    
               strAddOptText = " (optional)"   
                                    # Used to Add "Optional" to Not Required Fields 
               
               pnlMain = InterfaceAdd(strPanelName, 
                                      nXPos, 
                                      nYPos, 
                                      nPanelWidth, 
                                      nPanelHeight) 
               if pnlMain
                    
                    pnlMain.SetFontSize(nFontSize)
               else
                                
                    Log("Panel, '" + strPanelName + "', could not be created.", true)
               end
                                           
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USER-USERNAME-TEXT",
                                   "Username: " + @strUserName,
                                   nTextXOffset,
                                   nTextYTop) == false
                                
                    Log("Text field, 'REVCOM-USER-USERNAME-TEXT', could not be created.", true)  
               end  
               
               if @boolLoggedIn == false
                                           
                    if (inpInteract = InterfaceInputAdd(strPanelName,
                                                        "REVCOM-USER-USERNAME-INPUT",
                                                        nInpXOffset,
                                                        nInpYTop,
                                                        nInpWidth,
                                                        nInpHeight,
                                                        true))
                                                        
                         inpInteract.SetFontSize(nFontSize)
                    else
                                     
                         Log("Input field, 'REVCOM-USER-USERNAME-INPUT', could not be created.", true)    
                    end
               else
                    
                    strTitle = "UPDATE USER"
               end
               
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USER-TITLE-TEXT",
                                    strTitle,
                                    nPanelWidth / 2 - 45,
                                    10) == false
                                     
                    Log("Text field, 'REVCOM-USER-TITLE-TEXT', could not be created.", true)
               end
                                       
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USER-PASSWORD-TEXT",
                                   "Password: ",
                                   nTextXOffset,
                                   nTextYTop + nTextYOffset) == false
                                
                    Log("Text field, 'REVCOM-USER-PASSWORD-TEXT', could not be created.", true)     
               end            
                                 
               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-USER-PASSWORD-INPUT",
                                                   nInpXOffset,
                                                   nInpYTop + nInpYOffset,
                                                   nInpWidth,
                                                   nInpHeight))

                    inpInteract.SetFontSize(nFontSize)
                    inpInteract.SetPrivate(true)  
                    inpInteract.SetAddedCharLimit(16)     
               else
             
                    Log("Input field, 'REVCOM-USER-PASSWORD-INPUT', could not be created.", true) 
               end
                                                          
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USER-PASSCONFIRM-TEXT",
                                   "Confirm Password: ",
                                   nTextXOffset,
                                   nTextYTop + (nTextYOffset * 2)) == false
             
                    Log("Text field, 'REVCOM-USER-PASSCONFIRM-TEXT', could not be created.", true) 
               end                   
               
               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-USER-PASSCONFIRM-INPUT",
                                                   nInpXOffset,
                                                   nInpYTop + (nInpYOffset * 2),
                                                   nInpWidth,
                                                   nInpHeight))

                    inpInteract.SetFontSize(nFontSize)
                    inpInteract.SetPrivate(true)  
                    inpInteract.SetAddedCharLimit(16)     
               else
             
                    Log("Input field, 'REVCOM-USER-PASSCONFIRM-INPUT', could not be created.", true) 
               end 
                                 
               if boolAddPhoneNum == true
                    
                    if boolRequirePhoneNum == true
                         
                         strAddOptText = ""

                         if (inpInteract = InterfaceInputAdd(strPanelName,
                                                             "REVCOM-USER-PHONEREQ-INPUT",
                                                             0,
                                                             0,
                                                             0,
                                                             0))
                              
                              inpInteract.Show(false) 
                         else
          
                              Log("Input field, 'REVCOM-USER-PHONEREQ-INPUT', could not be created.", true) 
                         end   
                    end
                                                
                    if InterfaceTextAdd(strPanelName,
                                        "REVCOM-USER-PHONENUM-TEXT",
                                        "Phone Number" + strAddOptText + ":",
                                        nTextXOffset,
                                        nTextYTop + (nTextYOffset * 3)) == false   

                         Log("Text field, 'REVCOM-USER-PHONENUM-TEXT', could not be created.", true) 
                    end 
                             
                    if (inpInteract = InterfaceInputAdd(strPanelName,
                                                        "REVCOM-USER-PHONENUM-INPUT",
                                                        nInpXOffset,
                                                        nInpYTop + (nInpYOffset * 3),
                                                        nInpWidth,
                                                        nInpHeight))
     
                         inpInteract.SetFontSize(nFontSize)
                         inpInteract.SetAddedCharLimit(16) 
                         inpInteract.SetTextType(2)
                    else

                         Log("Input field, 'REVCOM-USER-PHONENUM-INPUT', could not be created.", true) 
                    end                    
                    
                    if InterfaceTextAdd(strPanelName,
                                        "REVCOM-USER-MSERVICE-TEXT",
                                        "Mobile Service" + strAddOptText + ":",
                                        nTextXOffset,
                                        nTextYTop + (nTextYOffset * 4)) == false

                         Log("Text field, 'REVCOM-USER-MSERVICE-TEXT', could not be created.", true)                
                    end 
                                                
                    if (inpInteract = InterfaceInputAdd(strPanelName,
                                                        "REVCOM-USER-MSERVICE-INPUT",
                                                        nInpXOffset,
                                                        nInpYTop + (nInpYOffset * 4),
                                                        nInpWidth - 50,
                                                        nInpHeight))

                         inpInteract.Show(false)
                         
                         if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                              "REVCOM-USER-MSERVICE-BTNLIST", 
                                                              nInpXOffset + (nInpWidth - 50), 
                                                              nInpYTop + (nInpYOffset * 4), 
                                                              50,
                                                              nInpHeight,
                                                              "LIST"))
     
                              inpInteract.SetFontSize(nFontSize)
                              
                              UserInfoMServiceBtnListFuncSetup()
                         else
     
                              Log("Button, 'REVCOM-USER-MSERVICE-BTNLIST', could not be created.", true) 
                              
                         end
                    else
     
                         Log("Input field, 'REVCOM-USER-MSERVICE-INPUT', could not be created.", true) 
                    end  
               end
                                 
               if boolAddEmail == true
                    
                    if boolRequireEmail == true
                         
                         strAddOptText = ""

                         if (inpInteract = InterfaceInputAdd(strPanelName,
                                                             "REVCOM-USER-EMAILREQ-INPUT",
                                                             0,
                                                             0,
                                                             0,
                                                             0))
                             
                              inpInteract.Show(false) 
                         else
          
                              Log("Input field, 'REVCOM-USER-EMAILREQ-INPUT', could not be created.", true) 
                         end  
                         
                    else
                         
                         strAddOptText = " (optional)"  
                    end
                                                
                    if InterfaceTextAdd(strPanelName,
                                        "REVCOM-USER-EMAIL-TEXT",
                                        "E-mail Address" + strAddOptText + ":",
                                        nTextXOffset,
                                        nTextYTop + (nTextYOffset * 5)) == false

                         Log("Text field, 'REVCOM-USER-EMAIL-TEXT', could not be created.", true) 
                    end    
                                                
                    if (inpInteract = InterfaceInputAdd(strPanelName,
                                                        "REVCOM-USER-EMAIL-INPUT",
                                                        nInpXOffset,
                                                        nInpYTop + (nInpYOffset * 5),
                                                        nInpWidth,
                                                        nInpHeight))
                                 
                         inpInteract.SetFontSize(nFontSize)
                    else

                         Log("Input field, 'REVCOM-USER-EMAIL-INPUT', could not be created.", true) 
                    end  
               end       
               
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USER-STATUS-TEXT",
                                   "Status: ",
                                   nTextXOffset,
                                   nTextYTop + (nTextYOffset * 6)) == false

                    Log("Text field, 'REVCOM-USER-STATUS-TEXT', could not be created.", true)                
               end    

               if (inpInteract = InterfaceButtonAdd(strPanelName,  
                                                    "REVCOM-USER-SUBMIT-BTN", 
                                                    nPanelWidth / 2 - 96,
                                                    nPanelHeight - 60,
                                                    65, 
                                                    45,
                                                    "SUBMIT"))
                            
                    inpInteract.SetFontSize(nFontSize)
                    
                    UserInfoSubmitBtnFuncSetup(inpInteract)
               else
                    
                    Log("Button, 'REVCOM-USER-SUBMIT-BTN', could not be created.", true)   
               end 
               
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-USER-CLOSE-BTN", 
                                                    nPanelWidth / 2 - 31,
                                                    nPanelHeight - 60,
                                                    65, 
                                                    45,
                                                    "CLOSE"))
                            
                    inpInteract.SetFontSize(nFontSize)
                    
                    if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false

                         Log("Button, 'REVCOM-USER-CLOSE-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false

                         Log("Button, 'REVCOM-USER-CLOSE-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseClickFuncCall(self, "UserInfoCloseBtnClickEvent") == false

                         Log("Button, 'REVCOM-USER-CLOSE-BTN', mouse click event could not be setup.", true) 
                    end
               else
                    
                    Log("Button, 'REVCOM-USER-CLOSE-BTN', could not be created.", true)   
               end  
               
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-USER-LOGIN-BTN", 
                                                    nPanelWidth / 2 + 34,
                                                    nPanelHeight - 60,
                                                    65, 
                                                    45,
                                                    "LOGIN"))
                            
                    inpInteract.SetFontSize(nFontSize)
                    
                    UserInfoLoginBtnFuncSetup(inpInteract)
               else
                    
                    Log("Button, 'REVCOM-USER-LOGIN-BTN', could not be created.", true)   
               end           
          end

          def self.LoginCreateSetup(nXPos = Graphics.width / 2 - 200, 
                                    nYPos = Graphics.height / 2 - 100)
          
               strPanelName = "REVCOM-USERLOGIN-PANEL" 
                                    # Panel Name     
          #               pnlMain = nil        # Main Panel  
               nPanelWidth = 400    # Width of Panel
               nPanelHeight = 240   # Height of Panel  
               nTextXOffset = 15    # X-Axis Offset of Text
               nTextYTop = 55       # Starting Y-Axis Position of Text
               nTextYOffset = 40    # Starting Y-Axis Offset of Text
               nInpWidth = 175      # Width of Input
               nInpHeight = 40      # Height of Input
               nInpXOffset = 200    # X-Axis Offset of Input
               nInpYTop = 55        # Starting Y-Axis Position of Input
               nInpYOffset = 40     # Starting Y-Axis Offset of Input
               inpInteract = nil    # Interactive Object       
               nFontSize = 14       # Stardard Font Size    
               
               pnlMain = InterfaceAdd(strPanelName, 
                                      nXPos, 
                                      nYPos, 
                                      nPanelWidth, 
                                      nPanelHeight) 
               if pnlMain
                    
                    pnlMain.SetFontSize(nFontSize)
               else
                                
                    Log("Panel, '" + strPanelName + "', could not be created.", true)
               end
                                           
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USERLOGIN-TITLE-TEXT",
                                   "LOGIN",
                                   nPanelWidth / 2 - 25,
                                   10) == false
                                
                    Log("Text field, 'REVCOM-USERLOGIN-TITLE-TEXT', could not be created.", true)
               end
                                           
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USERLOGIN-USERNAME-TEXT",
                                   "Username: ",
                                   nTextXOffset,
                                   nTextYTop) == false
                                
                    Log("Text field, 'REVCOM-USERLOGIN-USERNAME-TEXT', could not be created.", true)  
               end  
                                           
               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-USERLOGIN-USERNAME-INPUT",
                                                   nInpXOffset,
                                                   nInpYTop,
                                                   nInpWidth,
                                                   nInpHeight,
                                                   true))
                                                   
                    inpInteract.SetFontSize(nFontSize)
               else
                                
                    Log("Input field, 'REVCOM-USERLOGIN-USERNAME-INPUT', could not be created.", true)    
               end
                                       
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USERLOGIN-PASSWORD-TEXT",
                                   "Password: ",
                                   nTextXOffset,
                                   nTextYTop + nTextYOffset) == false
                                
                    Log("Text field, 'REVCOM-USERLOGIN-PASSWORD-TEXT', could not be created.", true)     
               end            
                                 
               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-USERLOGIN-PASSWORD-INPUT",
                                                   nInpXOffset,
                                                   nInpYTop + nInpYOffset,
                                                   nInpWidth,
                                                   nInpHeight))
          
                    inpInteract.SetFontSize(nFontSize)
                    inpInteract.SetPrivate(true)  
                    inpInteract.SetAddedCharLimit(16)     
               else
             
                    Log("Input field, 'REVCOM-USERLOGIN-PASSWORD-INPUT', could not be created.", true) 
               end 
               
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-USERLOGIN-STATUS-TEXT",
                                   "Status: ",
                                   nTextXOffset,
                                   nTextYTop + (nTextYOffset * 2)) == false
          
                    Log("Text field, 'REVCOM-USERLOGIN-STATUS-TEXT', could not be created.", true)                
               end    
               
               if @boolLoggedIn == false
          
                    if (inpInteract = InterfaceButtonAdd(strPanelName,  
                                                         "REVCOM-USERLOGIN-SUBMIT-BTN", 
                                                         nPanelWidth / 2 - 96,
                                                         nInpYTop + (nInpYOffset * 3) + 10,
                                                         65, 
                                                         45,
                                                         "SUBMIT"))
                                 
                         inpInteract.SetFontSize(nFontSize)
                         
                         UserLoginSubmitBtnFuncSetup(inpInteract)
                    else
                         
                         Log("Button, 'REVCOM-USERLOGIN-SUBMIT-BTN', could not be created.", true)   
                    end  
               elsif InterfaceTextSet(strPanelName,
                                      "REVCOM-USERLOGIN-STATUS-TEXT",
                                      "Status: User already logged in.") == false
          
                    Log("Text field, 'REVCOM-USERLOGIN-STATUS-TEXT', could not be set for logged in message.", true)
               end 
               
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-USERLOGIN-CLOSE-BTN", 
                                                    nPanelWidth / 2 - 31,
                                                    nInpYTop + (nInpYOffset * 3) + 10,
                                                    65, 
                                                    45,
                                                    "CLOSE"))
                            
                    inpInteract.SetFontSize(nFontSize)
                    
                    if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CLOSE-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CLOSE-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseClickFuncCall(self, "UserLoginCloseBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-USERLOGIN-CLOSE-BTN', mouse click event could not be setup.", true) 
                    end
               else
                    
                    Log("Button, 'REVCOM-USERLOGIN-CLOSE-BTN', could not be created.", true)   
               end   
               
               if @boolLoggedIn == false

                    if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                         "REVCOM-USERLOGIN-CREATE-BTN", 
                                                         nPanelWidth / 2 + 34,
                                                         nInpYTop + (nInpYOffset * 3) + 10,
                                                         65, 
                                                         45,
                                                         "CREATE"))
                                 
                         inpInteract.SetFontSize(nFontSize)

                         UserLoginCreateBtnFuncSetup(inpInteract)
                    else
                         
                         Log("Button, 'REVCOM-USERLOGIN-CREATE-BTN', could not be created.", true)   
                    end  
               end   
          end
          
          def self.SessionGroupSetup(nXPos = Graphics.width / 2 - 200, 
                                     nYPos = Graphics.height / 2 - 100, 
                                     boolAddTimeInput = false)
          
               strPanelName = "REVCOM-SESSIONGROUP-PANEL" 
                                    # Panel Name     
          #               pnlMain = nil        # Main Panel  
               nPanelWidth = 400    # Width of Panel
               nPanelHeight = 300   # Height of Panel  
               nTextXOffset = 15    # X-Axis Offset of Text
               nTextYTop = 55       # Starting Y-Axis Position of Text
               nTextYOffset = 40    # Starting Y-Axis Offset of Text
               nInpWidth = 225      # Width of Input
               nInpHeight = 40      # Height of Input
               nInpXOffset = 150    # X-Axis Offset of Input
               nInpYTop = 55        # Starting Y-Axis Position of Input
               nInpYOffset = 40     # Starting Y-Axis Offset of Input
               inpInteract = nil    # Interactive Object       
               nFontSize = 14       # Stardard Font Size   
               strStatusMsg = ""    # Default Status Message to Display

               pnlMain = InterfaceAdd(strPanelName, 
                                      nXPos, 
                                      nYPos, 
                                      nPanelWidth, 
                                      nPanelHeight) 
               if pnlMain
                    
                    pnlMain.SetFontSize(nFontSize)
               else
                                
                    Log("Panel, '" + strPanelName + "', could not be created.", true)
               end
                                           
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-SESSIONGROUP-TITLE-TEXT",
                                   "SESSION GROUPS",
                                   0,
                                   10) == false
                                
                    Log("Text field, 'REVCOM-SESSIONGROUP-TITLE-TEXT', could not be created.", true)
               end
                                           
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-SESSIONGROUP-START-TEXT",
                                   "Start Session Group: ",
                                   nTextXOffset,
                                   nTextYTop) == false
                                
                    Log("Text field, 'REVCOM-SESSIONGROUP-START-TEXT', could not be created.", true)  
               end  
                    
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-SESSIONGROUP-START-BTN", 
                                                    nInpXOffset, 
                                                    nInpYTop, 
                                                    60,
                                                    nInpHeight,
                                                    "START"))

                    inpInteract.SetFontSize(nFontSize)
                    
                    if @boolInSessionGroup == false && @boolLoggedIn == true
               
                         SessionGroupStartBtnFuncSetup(inpInteract)
                    else
                         
                         if @boolLoggedIn == false

                              strStatusMsg = "Must be logged in."
                         elsif @boolInSessionGroup == true

                              strStatusMsg = "Already in session group."
                         end
                         
                         BtnDisableEvent(inpInteract)
                    end
               else

                    Log("Button, 'REVCOM-SESSIONGROUP-START-BTN', could not be created.", true) 
               end
               
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-SESSIONGROUP-INVITE-TEXT",
                                   "Invite: ",
                                   nTextXOffset,
                                   nTextYTop + nTextYOffset) == false

                    Log("Text field, 'REVCOM-SESSIONGROUP-INVITE-TEXT', could not be created.", true)                
               end 
                                          
               if (inpInteract = InterfaceInputAdd(strPanelName,
                                                   "REVCOM-SESSIONGROUP-INVITE-INPUT",
                                                   nInpXOffset,
                                                   nInpYTop + nInpYOffset,
                                                   nInpWidth - 50,
                                                   nInpHeight))

                    inpInteract.SetFontSize(nFontSize)
                    
                    if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                         "REVCOM-SESSIONGROUP-INVITE-BTNLIST", 
                                                         nInpXOffset + (nInpWidth - 50), 
                                                         nInpYTop + nInpYOffset, 
                                                         50,
                                                         nInpHeight,
                                                         "LIST"))

                         inpInteract.SetFontSize(nFontSize)
                         
                         if @boolInSessionGroup == true

                              SessionGroupInviteListBtnFuncSetup(inpInteract)
                         else
                              
                              BtnDisableEvent(inpInteract)
                         end
                    else

                         Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTNLIST', could not be created.", true) 
                         
                    end
               else

                    Log("Input field, 'REVCOM-SESSIONGROUP-INVITE-INPUT', could not be created.", true) 
               end  
                                       
               if inpInteract = InterfaceInputAdd(strPanelName,
                                                  "REVCOM-SESSIONGROUP-TIMELIMIT-INPUT",
                                                  nInpXOffset,
                                                  nInpYTop + (nInpYOffset * 2),
                                                  nInpWidth,
                                                  nInpHeight)

                    if boolAddTimeInput == true
                         
                         if InterfaceTextAdd(strPanelName,
                                             "REVCOM-SESSIONGROUP-TIMELIMIT-TEXT",
                                             "Invite Time Limit (Secs): ",
                                             nTextXOffset,
                                             nTextYTop + (nTextYOffset * 2)) == false
          
                              Log("Text field, 'REVCOM-SESSIONGROUP-TIMELIMIT-TEXT', could not be created.", true)                
                         end 
                    
                         inpInteract.SetFontSize(nFontSize)
                    else
                         
                         inpInteract.Show(false)
                    end
                    
                    inpInteract.AddText("30")
               else

                    Log("Input field, 'REVCOM-SESSIONGROUP-TIMELIMIT-INPUT', could not be created.", true) 
               end  
               
               if InterfaceTextAdd(strPanelName,
                                   "REVCOM-SESSIONGROUP-STATUS-TEXT",
                                   "Status: " + strStatusMsg,
                                   nTextXOffset,
                                   nTextYTop + (nTextYOffset * 3)) == false

                    Log("Text field, 'REVCOM-SESSIONGROUP-STATUS-TEXT', could not be created.", true)                
               end  

               if (inpInteract = InterfaceButtonAdd(strPanelName,  
                                                    "REVCOM-SESSIONGROUP-INVITE-BTN", 
                                                    nPanelWidth / 2 - 65,
                                                    nInpYTop + (nInpYOffset * 4) + 10,
                                                    65, 
                                                    45,
                                                    "INVITE"))
                            
                    inpInteract.SetFontSize(nFontSize)

                    if @boolInSessionGroup == true

                         SessionGroupInviteBtnFuncSetup(inpInteract)
                    else
                         
                         BtnDisableEvent(inpInteract)
                    end
               else
                    
                    Log("Button, 'REVCOM-SESSIONGROUP-INVITE-BTN', could not be created.", true)   
               end
               
               if (inpInteract = InterfaceButtonAdd(strPanelName, 
                                                    "REVCOM-SESSIONGROUP-CLOSE-BTN", 
                                                    nPanelWidth / 2,
                                                    nInpYTop + (nInpYOffset * 4) + 10,
                                                    65, 
                                                    45,
                                                    "CLOSE"))
                            
                    inpInteract.SetFontSize(nFontSize)
                    
                    if inpInteract.SetMouseInFuncCall(self, "BtnInEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-CLOSE-BTN', mouseover event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseOutFuncCall(self, "BtnOutEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-CLOSE-BTN', mouseout event could not be setup.", true) 
                    end
                    
                    if inpInteract.SetMouseClickFuncCall(self, "SessionGroupCloseBtnClickEvent") == false
          
                         Log("Button, 'REVCOM-SESSIONGROUP-CLOSE-BTN', mouse click event could not be setup.", true) 
                    end
               else
                    
                    Log("Button, 'REVCOM-SESSIONGROUP-CLOSE-BTN', could not be created.", true)   
               end 
          end

          def self.SetMapStartFunc(nMapID, 
                                   objDestination, 
                                   strMethodName, 
                                   mxValue = nil, 
                                   boolRemoveAfter = true)
               
               hExecuteInfo = {"EXECUTE" => {"OBJECT" => objDestination, 
                                             "METHOD" => strMethodName,
                                             "VALUE" => mxValue},
                               "REMOVE" => boolRemoveAfter}
          
               if !@aahMapFuncList[nMapID]
                    
                    @aahMapFuncList[nMapID] = [];  
               end                
                               
               @aahMapFuncList[nMapID].push(hExecuteInfo)

               return hExecuteInfo.object_id
          end
                    
          def self.RemoveMapStartFunc(strObjectID)
               
               nMaps = @aahMapFuncList.length()
                                    # Count of Maps
               # nMapFuncs = 0       # Count of Map Functions
               # ahMapSelectFuncs    # List of Functions for Selected Map
               nMapIndex = -1       # Index of Scene Type with Function to Delete
               nMapFuncIndex = -1   # Index of Scene Type Function to Delete
               nMapCounter = 0      # Counter for Map Loop
               nMapFuncCounter = 0  # Counter for Map Function Loop
                
               for nMapCounter in 0...nMaps
               
                    if @aahMapFuncList[nMapCounter]
                         
                         ahMapSelectFuncs = @aahMapFuncList[nMapCounter]
                         nMapFuncs = ahMapSelectFuncs.length
                     
                         for nMapFuncCounter in 0...nMapFuncs
                              
                              if ahMapSelectFuncs[nMapFuncCounter].object_id == strObjectID
               
                                   nMapIndex = nMapCounter
                                   nMapFuncIndex = nMapFuncCounter
                                   break
                              end
                         end
                         
                         if nMapFuncIndex >= 0
                              
                              break
                         end
                    end
               end
               
               if nMapIndex >= 0 && nMapFuncIndex >= 0
                    
                    @aahMapFuncList[nMapIndex].delete_at(nMapFuncIndex)
               end
          end

          def self.SetImage(strImgDesign, 
                            strSpritesheetPathName, 
                            nType,
                            nWidth, 
                            nHeight,
                            nXPos, 
                            nYPos,
                            boolLoad = false,
                            boolDispose = true)
                            
#               bmImage = Bitmap.new(nWidth, nHeight)
                                    # Holder for Completed Image 
               bmSpritesheet = nil  # Holder for Constructed Image
#               aFilePathParts = strSpritesheetPathName.split('\\')
                                    # Parts of the Spritesheet Path
               
               if boolLoad == true
                    
                    aFilePathParts = strSpritesheetPathName.split('\\')
     
                    if aFilePathParts.length > 0
                    
                         bmSpritesheet = Cache.load_bitmap(strSpritesheetPathName.gsub(aFilePathParts[aFilePathParts.length - 1], ""), 
                                                           aFilePathParts[aFilePathParts.length - 1])
                    end
               end
               
               if strImgDesign &&
                  strImgDesign != ""
                  
                    strSpritesheetPathName = strSpritesheetPathName.gsub('/', '\\')
                    bmImage = Bitmap.new(nWidth, nHeight)
                         
                    # Load Image File If Not Already Loaded
                    aFilePathParts = strSpritesheetPathName.split('\\')
               
                    if !bmSpritesheet && aFilePathParts.length > 0
          
                         case nType
                              
                              when 0
                                   
                                   bmSpritesheet = Cache.character(aFilePathParts[aFilePathParts.length - 1])
                              
                              when 1
                                   
                                   bmSpritesheet = Cache.tileset(aFilePathParts[aFilePathParts.length - 1])
                              
                              when 2
                                   
                                   bmSpritesheet = Cache.animation(aFilePathParts[aFilePathParts.length - 1], 0)
          
                              when 3
                                   
                                   bmSpritesheet = Cache.system(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 4
                                  
                                   bmSpritesheet = Cache.picture(aFilePathParts[aFilePathParts.length - 1])
     
                              when 5
                                  
                                   bmSpritesheet = Cache.battleback1(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 6
                                  
                                   bmSpritesheet = Cache.battleback2(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 7
                                  
                                   bmSpritesheet = Cache.battler(aFilePathParts[aFilePathParts.length - 1], 0)
                                   
                              when 8
                                  
                                   bmSpritesheet = Cache.face(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 9
                                  
                                   bmSpritesheet = Cache.parallax(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 10
                                  
                                   bmSpritesheet = Cache.title1(aFilePathParts[aFilePathParts.length - 1])
                                   
                              when 11
                                  
                                   bmSpritesheet = Cache.title2(aFilePathParts[aFilePathParts.length - 1])
                                   
                         end
                    end
          
                    if bmSpritesheet 
                         
                         bmImage.blt(0, 
                                     0, 
                                     bmSpritesheet, 
                                     Rect.new(nXPos, nYPos, nWidth, nHeight))
                    end
                    
                    if @hhImages.has_key?(strImgDesign) == true &&
                       boolDispose == true
                         
                         @hhImages[strImgDesign]["BITMAP"].dispose()
                    end
                    
                    @hhImages[strImgDesign] = {
          
                         "SPRITESHEET" => strSpritesheetPathName,
                         "TYPE" => nType,
                         "WIDTH" => nWidth,
                         "HEIGHT" => nHeight,
                         "X-POSITION" => nXPos,
                         "Y-POSITION" => nYPos,
                         "BITMAP" => bmImage
                    }
               else
                    
                    Log("During setting image, invalid information was sent.")               
               end
          end
          
          # Get Specified Image
          def self.GetImage(strImgDesign)
          
               bmImage = nil             # Created Bitmap
               
               if @hhImages.has_key?(strImgDesign) == true
                    
                    bmImage = @hhImages[strImgDesign]["BITMAP"]
               end
               
               return bmImage
          end
                    
          def self.SetMouseImage(strImageDesign, nZPos = 100000, nAngle = 0)
               
               RemoveMouseImage()
               
               if @hWindow
                    
                    @spMouse = Sprite.new
                    @spMouse.bitmap = GetImage(strImageDesign)
                    @spMouse.z = nZPos
                    @spMouse.angle = nAngle
                    @spMouse.update

               else 

                    Log("During setting mouse image, window access was not found. " + 
                        " If calling at start of app, put call in a timer")
               end
          end
          
          def self.SetMouseOffset(nXOffset = 0, nYOffset = 0, nZPos = 100000, nAngle = 0)
          
               @anMouseOffset[0] = nXOffset
               @anMouseOffset[1] = nYOffset
               @anMouseOffset[2] = nZPos
               @anMouseOffset[3] = nAngle
          end
          
          def self.RemoveMouseImage

               if @spMouse
                    
                    @spMouse.bitmap.dispose()
                    @spMouse.dispose()
                    @spMouse = nil
               end
          end
          
          def self.UpdateHashSafe(hOriginal, boolDoUpdate = true)
               
               hClone = nil              # Clone for Update
               
               if hOriginal.is_a?(Hash) == true
               
                    hClone = hOriginal.clone
                    
                    @ahHashUpdates.push({'ORIGINAL' => hOriginal,
                                         'CLONE' => hClone,
                                         'UPDATE' => boolDoUpdate})
               end
               
               return hClone
          end
          
          def self.SetTimer(strDesign, 
                            objDestination, 
                            strMethodName,
                            nTimeInMillis,
                            tmStart = Time.now,
                            nDelayInMillis = 0,
                            nIntervals = 0,
                            boolContinous = false,
                            mxParams = nil)
          
               if strDesign &&  
                  strDesign != "" &&
                  objDestination &&  
                  strMethodName &&
                  strMethodName != ""  

                    if nTimeInMillis <= 0

                         nTimeInMillis = 1
                    end    
          
                    UpdateHashSafe(@hhTimers)[strDesign] = {"OBJECT" => objDestination,
                                                            "METHOD" => strMethodName,
                                                            "VALUE" => nil,
                                                            "DELAY" => nDelayInMillis,
                                                            "START" => tmStart,
                                                            "LENGTH" => nTimeInMillis,
                                                            "INTERVALS" => nIntervals,
                                                            "CONTINOUS" => boolContinous,
                                                            "PARAMS" => mxParams}
               else
                    
                    Log("During setting timer, invalid information was sent.")                        
               end
          end
          
          def self.RemoveTimer(strDesign)
          
               if strDesign &&  
                  strDesign != "" &&
                  @hhTimers.has_key?(strDesign) == true
          
                    @hhTimers.delete(strDesign)
               else
                    
                    Log("During removing timer, invalid information was sent.")                        
               end
          end
          
          def self.RemoveAllTimers
          
               @hhTimers.clear()
          end
          
          def self.CheckTimer(strDesign)
          
               boolFound = false         # Indicator That Timer was Found
               
               if strDesign &&  
                  strDesign != ""
          
                  boolFound = @hhTimers.has_key?(strDesign)             
               end
               
               return boolFound
          end
          
          def self.SetActiveWindow(strWindowTitle = nil)

               if !strWindowTitle && $data_system 
                    
                    strWindowTitle = $data_system.game_title
               end
               
               if strWindowTitle
               
                    @hWindow = Win32API.new('user32', 'FindWindow', 'PP', 'I').call("RGSS Player", strWindowTitle)
               end
               
          end
          
          def self.KeyPress(strKeyValue)
               
               boolPressed = false       # Indicator That Key was Pressed
               
               if @w32Keys.call(strKeyValue.ord).between?(0, 1) == false  
                         
                    boolPressed = true               
                    
               end
               
               return boolPressed
          end
          
          def self.KeySpacePress
               
               boolPressed = false
               
               if @w32Keys.call(0x20).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end
          
          def self.KeyBackPress
               
               boolPressed = false
               
               if @w32Keys.call(0x08).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end
          
          def self.KeyEnterPress
               
               boolPressed = false
               
               if @w32Keys.call(0x0D).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end
          
          def self.KeyTabPress
               
               boolPressed = false
               
               if @w32Keys.call(0x09).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end
          
          def self.KeyShiftPress
               
               boolPressed = false
               
               if @w32Keys.call(0x10).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end

          def self.KeyPeriodPress
               
               boolPressed = false
               
               if @w32Keys.call(0xBE).between?(0, 1) == false 
                    
                    boolPressed = true
               end
               
               return boolPressed
          end
          
          def self.MouseLeftClick
               
               return MouseClick(1)
          end
          
          def self.MouseRightClick
               
               return MouseClick(2)
          end
          
          def self.ToggleShiftUpcase
               
               if @boolUseShiftKeyUpcase == false
                    
                    @boolUseShiftKeyUpcase = true
               else
                    
                    @boolUseShiftKeyUpcase = false
               end
          end
          
          def self.HasKeyMapping(mxKeyValue)

               begin

                    if mxKeyValue.is_a?(String) == false
                         
                         mxKeyValue = mxKeyValue.to_s
                    end
                         
               rescue
                    
               end
               
               return (mxKeyValue.is_a?(String) == true && mxKeyValue.length == 1) && 
                      (@strInputFocusDesign != "" && 
                       (@hKeyList.values.compact.count > 0 || 
                        @hBarList.values.compact.count > 0))
          end

          def self.InterfaceAdd(strDesign, 
                                nXPos = 0, 
                                nYPos = 0, 
                                nWidth = Graphics.width, 
                                nHeight = Graphics.height, 
                                nMode = 0,
                                boolSafeCreate = false)
          
               giComponment = nil        # New Interface
               
               if strDesign && strDesign != ""
          
                    if @hhInterfaceList.has_key?(strDesign) == false
                    
                        giComponment = BGMRPGM_Interface.new(nXPos, nYPos, nWidth, nHeight, nMode)
                
                        if boolSafeCreate == true

                             UpdateHashSafe(@hhInterfaceList)[strDesign] = giComponment
                         else 

                             @hhInterfaceList[strDesign] = giComponment
                         end
                    else
                      
                        Log("During adding interface, its designation, '" + strDesign + "' was already in use.")
                    end
               end 
               
               return giComponment
          end
          
          def self.InterfaceGet(strDesign)
           
               giComponment = nil        # Registered Interface 
                
               if strDesign && strDesign != "" && @hhInterfaceList.has_key?(strDesign) == true
             
                    giComponment = @hhInterfaceList[strDesign]
                end
                
                return giComponment
           end
          
           def self.InterfaceSetMode(strDesign, nNewMode)
                
                if @hhInterfaceList.has_key?(strDesign) == true
                
                     @hhInterfaceList[strDesign].SetMode(nNewMode)
                end
           end
          
           def self.InterfaceTextAdd(strDesign, 
                                     strCompDesign, 
                                     strText, 
                                     nXOffset = 0, 
                                     nYOffset = 0) 
           
                boolAdded = false         # Indicator That Text Was Added
                
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
          
                     boolAdded = @hhInterfaceList[strDesign].AddText(strCompDesign, strText, nXOffset, nYOffset) 
                     
                     if boolAdded == true
           
                          @hhInterfaceList[strDesign].Draw()
                     end
                else
                   
                     Log("During adding interface text, invalid information was sent.")
                end
                
                return boolAdded
           end
           
           def self.InterfaceBarAdd(strDesign, 
                                    strCompDesign, 
                                    nXOffset, 
                                    nYOffset, 
                                    nWidth, 
                                    nHeight = 15, 
                                    nType = 0, 
                                    nValue = 0, 
                                    nLimit = 100, 
                                    nColorBar = 0, 
                                    nColorBack = 19,
                                    fTimeLimitInMillis = 5000) 
          
               giComponment = nil        # Registered Interface 
               
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
          
                    giComponment = @hhInterfaceList[strDesign]
                    
                    if giComponment.AddBar(strCompDesign, 
                                           nXOffset, 
                                           nYOffset, 
                                           nWidth, 
                                           nHeight, 
                                           nType, 
                                           nValue, 
                                           nLimit, 
                                           nColorBar, 
                                           nColorBack,
                                           fTimeLimitInMillis) == true 
                                           
                         @hhInterfaceList[strDesign].Draw()
                    else 
                                                           
                         giComponment = nil
                    end
               else
                  
                    Log("During adding interface bar, invalid information was sent.")
               end
               
               return giComponment
           end
           
           def self.InterfaceInputAdd(strDesign, 
                                      strCompDesign, 
                                      nXOffset, 
                                      nYOffset, 
                                      nWidth, 
                                      nHeight,
                                      boolHasFocus = false,
                                      strDefaultText = nil)
           
                gdDialog = nil         # Created Game Dialog Box
          
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
          
                      if @hhInterfaceList[strDesign].CheckCompExists(strCompDesign, 2) == false
                      
                           gdDialog = @hhInterfaceList[strDesign].AddInput(strCompDesign, nXOffset, nYOffset, nWidth, nHeight, strDefaultText)
                           
                           if gdDialog
                                
                                @hhInterfaceList[strDesign].Draw()
                           end
                           
                           if boolHasFocus == true
                             
                                 InputFocus(strDesign, strCompDesign)
                           end
                      else
                        
                           Log("During adding interface input, its designation, '" + strCompDesign + "' was already in use for an input.")
                      end
                else
                    
                      Log("During adding interface input, invalid information was sent.")
                end
                
                return gdDialog
           end
          
           def self.InterfaceListAdd(strDesign, 
                                     strCompDesign,
                                     nXOffset, 
                                     nYOffset, 
                                     nItemWidth, 
                                     nItemHeight,
                                     nOffsetType = 0)
                                     
               boolAdded = false
          
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
          
                    if @hhInterfaceList[strDesign].CheckCompExists(strCompDesign, 3) == false
          
                         boolAdded = @hhInterfaceList[strDesign].AddList(strCompDesign, nXOffset, nYOffset, nItemWidth, nItemHeight, nOffsetType)
                    else
                       
                         Log("During adding interface list, its designation, '" + strCompDesign + "' was already in use for a list.")
                    end
               else
                  
                    Log("During adding interface list, invalid information was sent.")
               end
               
               return boolAdded
           end
          
          def self.InterfaceListItemAdd(strDesign, 
                                        strCompDesign,
                                        strItemDesign)
                                        
              boolAdded = false
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
                 
                   boolAdded = @hhInterfaceList[strDesign].AddListItem(strCompDesign, strItemDesign)
              else
                 
                   Log("During adding interface list item, invalid information was sent.")
              end
              
              return boolAdded
          end
          
           def self.InterfaceButtonAdd(strDesign, 
                                       strCompDesign, 
                                       nXOffset, 
                                       nYOffset, 
                                       nWidth, 
                                       nHeight,
                                       strText = nil)
           
                gdDialog = nil         # Created Game Dialog Box
           
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
           
                      if @hhInterfaceList[strDesign].CheckCompExists(strCompDesign, 4) == false
                      
                          gdDialog = @hhInterfaceList[strDesign].AddButton(strCompDesign, nXOffset, nYOffset, nWidth, nHeight, strText)
                      else
                        
                          Log("During adding interface button, its designation, '" + strCompDesign + "' was already in use for a button.")
                      end
                else
                    
                      Log("During adding interface button, invalid information was sent.")
                end
                
                return gdDialog
           end

           def self.InterfaceImageAdd(strDesign, 
                                     strCompDesign, 
                                     strImgDesign,
                                     nXOffset, 
                                     nYOffset, 
                                     nZPos = 100)
          
               bmImage = nil         # Created Image
          
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
          
                     if @hhInterfaceList[strDesign].CheckCompExists(strCompDesign, 5) == false
                     
                         bmImage = GetImage(strImgDesign);
                         
                         if @hhInterfaceList[strDesign].AddImage(strCompDesign, nXOffset, nYOffset, bmImage, nZPos) == false 
                         
                              bmImage = nil
                         end
                     else
                       
                         Log("During adding interface image, its designation, '" + strCompDesign + "' was already in use for a button.")
                     end
               else
                   
                     Log("During adding interface image, invalid information was sent.")
               end
               
               return bmImage
           end
           
           def self.InterfaceInputGet(strDesign, 
                                      strCompDesign)
            
                 gdDialog = nil         # Created Game Dialog Box
           
                 if strDesign && 
                    strDesign != "" && 
                    @hhInterfaceList.has_key?(strDesign) == true
           
                       gdDialog = @hhInterfaceList[strDesign].GetInput(strCompDesign)
                 end
                 
                 return gdDialog
            end
           
            def self.InterfaceListItemGet(strDesign, strCompDesign, strItemDesign)
           
                giListItem = nil         # List Item
                 
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
           
                     giListItem = @hhInterfaceList[strDesign].GetListInputButton(strCompDesign, strItemDesign)
                end
                
                return giListItem
            end
           
            def self.InterfaceButtonGet(strDesign, 
                                        strCompDesign)
            
                 gdDialog = nil         # Created Game Dialog Box
            
                 if strDesign && 
                    strDesign != "" && 
                    @hhInterfaceList.has_key?(strDesign) == true
            
                       gdDialog = @hhInterfaceList[strDesign].GetButton(strCompDesign)
                 end
                 
                 return gdDialog
            end
          
            def self.InterfaceTextSet(strDesign, 
                                      strCompDesign, 
                                      strText) 
          
               boolAdded = false         # Indicator That Text Was Added
               
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
          
                    boolAdded = @hhInterfaceList[strDesign].SetText(strCompDesign, strText) 
                    
                    if boolAdded == true
          
                         @hhInterfaceList[strDesign].Draw()
                    end
               else
                  
                    Log("During set interface text, invalid information was sent.")
               end
               
               return boolAdded
           end
          
            def self.InterfaceBarSetValue(strDesign, 
                                          strCompDesign, 
                                          nValue) 
          
               boolAdded = false         # Indicator That Bar was Updated
               
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
          
                    boolAdded = @hhInterfaceList[strDesign].SetBarValue(strCompDesign, nValue) 
                    
                    if boolAdded == true
          
                         @hhInterfaceList[strDesign].Draw()
                    end
               else
                  
                    Log("During set interface bar value, invalid information was sent.")
               end
               
               return boolAdded
           end
           
           def self.InterfaceRemove(strDesign, boolDispose = true)
          
                boolRemoved = false    # Indicator That Interface was Removed  
                 
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
              
                     if boolDispose == true

                          @hhInterfaceList[strDesign].dispose()
                     end

                     @hhInterfaceList.delete(strDesign)
                     boolRemoved = true
                     
                     if @strInterfaceFocusDesign == strDesign
                       
                          @strInterfaceFocusDesign = ""
                          @strInputFocusDesign = ""
                     end
                else
                  
                    Log("During removing interface, invalid information was sent.")
                end
                 
                return boolRemoved
           end
          
           def self.InterfaceCompRemove(strDesign, strCompDesign, boolDispose = true)
           
                boolRemoved = false    # Indicator That Interface Component was Removed  
                 
                if strDesign && strDesign != "" && @hhInterfaceList.has_key?(strDesign) == true 
              
                     boolRemoved = @hhInterfaceList[strDesign].RemoveComp(strCompDesign, boolDispose)
                     
                     if boolRemoved == true
                          
                          @hhInterfaceList[strDesign].Draw()
                     end
             
                     if @strInterfaceFocusDesign == strDesign &&
                        @strInputFocusDesign == strCompDesign
                       
                          @strInterfaceFocusDesign = ""
                          @strInputFocusDesign = ""
                     end
                else
                  
                    Log("During removing interface component, invalid information was sent.")
                end
                 
                return boolRemoved
           end
          
          def self.InterfaceListItemRemove(strDesign, 
                                           strCompDesign,
                                           strItemDesign)
                                        
              giListItem = nil
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
          
                   giListItem = @hhInterfaceList[strDesign].RemoveListItem(strCompDesign, strItemDesign)
              else
                 
                   Log("During removing interface list item, invalid information was sent.")
              end
              
              return giListItem
          end
          
          def self.InterfaceClear(strDesign)
                                        
              giInterface = nil
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
          
                   giInterface = @hhInterfaceList[strDesign].Clear
            
                   @strInterfaceFocusDesign = ""
                   @strInputFocusDesign = ""
              else
                 
                   Log("During clearing interface, invalid information was sent.")
              end
              
              return giInterface
          end
          
          def self.InputFocus(strDesign, strInputDesign)
               
                gdDialog = nil            # Focused Game Dialog
          
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
                   
                    gdDialog = @hhInterfaceList[strDesign].GetInput(strInputDesign)
            
                    if gdDialog
                         
                         InputBlur()
          
                         gdDialog.ShowCursor(true)
                         @strInterfaceFocusDesign = strDesign
                         @strInputFocusDesign = strInputDesign
                    else
          
                         Log("During giving focus to interface, '" + strDesign + "', input, its designation, '" + strInputDesign + "' was not found.") 
                    end
                end
               
                return gdDialog
          end
          
          def self.InputNextFocus(strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
               
                gdDialog = nil           # Focused Game Dialog
                strNextDesign = nil      # Next Designation for Focus
          
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
                   
                    strNextDesign = @hhInterfaceList[strDesign].FindNextInputDesign(strInputDesign)
            
                    if strNextDesign
          
                         InputBlur()
          
                         @strInterfaceFocusDesign = strDesign
                         @strInputFocusDesign = strNextDesign
                         
                         gdDialog = @hhInterfaceList[strDesign].GetInput(strNextDesign)
                         gdDialog.ShowCursor(true)
                    end
                end
               
                return gdDialog
          end
          
          def self.InputWrite(strText, strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
               boolAdded = false         # Indicator That Text Was Added
          
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true &&
                  strInputDesign &&
                  strInputDesign != ""
          
                    boolAdded = @hhInterfaceList[strDesign].AddInputText(strInputDesign, strText)
               end
               
               return boolAdded
          end
          
          def self.InputDelete(boolDeleteByWord = false, strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
               boolDeleted = false       # Indicator That Text Was Deleted
          
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true &&
                  strInputDesign &&
                  strInputDesign != ""
                    
                     boolDeleted = @hhInterfaceList[strDesign].DeleteInputText(strInputDesign, boolDeleteByWord)
               end
               
               return boolDeleted
          end
          
           def self.InputClear(strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
              boolDeleted = false       # Indicator That Text Was Deleted
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true &&
                 strInputDesign &&
                 strInputDesign != ""
                   
                    boolDeleted = @hhInterfaceList[strDesign].ClearInputText(strInputDesign)
              end
              
              return boolDeleted
          end
          
          def self.InputBlur
               
                gdDialog = nil            # Focused Game Dialog
          
                if @strInterfaceFocusDesign && 
                   @strInterfaceFocusDesign != "" &&
                   @strInputFocusDesign && 
                   @strInputFocusDesign != "" && 
                   @hhInterfaceList.has_key?(@strInterfaceFocusDesign) == true
                   
                    gdDialog = @hhInterfaceList[@strInterfaceFocusDesign].GetInput(@strInputFocusDesign)
            
                    if gdDialog
                         
                         gdDialog.ShowCursor(false)
                    else
          
                         Log("During blurring interface, '" + @strInterfaceFocusDesign + "', input, its designation, '" + @strInputFocusDesign + "' was not found.") 
                    end
                end
            
                @strInterfaceFocusDesign = ""
                @strInputFocusDesign = ""
               
                return gdDialog
          end
          
          def self.InputRead(strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign, boolClear = true)
          
               strValue = ""             # Input Value
               
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true &&
                  strInputDesign &&
                  strInputDesign != ""
                   
                    strValue = @hhInterfaceList[strDesign].ReadInputText(strInputDesign, boolClear)
               end
            
               return strValue
          end
          
          def self.InputSend(strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true &&
                 strInputDesign &&
                 strInputDesign != ""
                  
                   @hhInterfaceList[strDesign].SendInput(strInputDesign)
              end
          end
          
          def self.MouseInSend(strDesign, strInputDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
                  
                   @hhInterfaceList[strDesign].SendMouseIn(strInputDesign)
              end
          end
          
          def self.MouseOutSend(strDesign, strInputDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
                  
                   @hhInterfaceList[strDesign].SendMouseOut(strInputDesign)
              end
          end
          
          def self.MouseClickSend(strDesign, strInputDesign, nClickType = 0)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true
                  
                   @hhInterfaceList[strDesign].SendMouseClick(strInputDesign, nClickType)
              end
          end
          
          def self.InputSetSendFunc(objDestination, strFuncName, strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true &&
                 strInputDesign &&
                 strInputDesign != ""
                  
                   @hhInterfaceList[strDesign].SetInputSendFunc(strInputDesign, objDestination, strFuncName)
              else
             
                   Log("During setting interface input function text, invalid information was sent.")
              end
          end
          
          def self.ButtonSetSendFunc(strDesign, strInputDesign, objDestination, strFuncName)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true 
                  
                   @hhInterfaceList[strDesign].SetButtonSendFunc(strInputDesign, objDestination, strFuncName)
              else
             
                   Log("During setting interface button function for text, invalid information was sent.")
              end
          end
          
          def self.ButtonMouseInSetSendFunc(strDesign, strInputDesign, objDestination, strFuncName)
           
               if strDesign && 
                  strDesign != "" && 
                  @hhInterfaceList.has_key?(strDesign) == true
                   
                    @hhInterfaceList[strDesign].SetButtonMouseInSendFunc(strInputDesign, objDestination, strFuncName)
               else
              
                    Log("During setting interface button mouse in function for text, invalid information was sent.")
               end
          end
          
          def self.ButtonMouseOutSetSendFunc(strDesign, strInputDesign, objDestination, strFuncName)
            
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
                    
                     @hhInterfaceList[strDesign].SetButtonMouseOutSendFunc(strInputDesign, objDestination, strFuncName)
                else
               
                     Log("During setting interface button mouse out function for text, invalid information was sent.")
                end
          end
           
          def self.ButtonMouseClickSetSendFunc(strDesign, strInputDesign, objDestination, strFuncName, nClickType = 0)
            
                if strDesign && 
                   strDesign != "" && 
                   @hhInterfaceList.has_key?(strDesign) == true
                    
                     @hhInterfaceList[strDesign].SetButtonMouseClickSendFunc(strInputDesign, objDestination, strFuncName, nClickType)
                else
               
                     Log("During setting interface button mouse click function for text, invalid information was sent.")
                end
          end
          
          def self.InputRemoveSendFuncs(strDesign = @strInterfaceFocusDesign, strInputDesign = @strInputFocusDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true &&
                 strInputDesign &&
                 strInputDesign != ""
                  
                   @hhInterfaceList[strDesign].RemoveInputSendFuncs(strInputDesign)
              else
             
                   Log("During clearing interface input text functions, invalid information was sent.")
              end
          end
          
          def self.ButtonRemoveSendFuncs(strDesign, strInputDesign)
          
              if strDesign && 
                 strDesign != "" && 
                 @hhInterfaceList.has_key?(strDesign) == true &&
                 strInputDesign &&
                 strInputDesign != ""
                  
                   @hhInterfaceList[strDesign].RemoveButtonSendFuncs(strInputDesign)
              else
             
                   Log("During clearing interface input button functions, invalid information was sent.")
              end
          end
          
          def self.SetInterfaceFrame(strDesign, strImgFileDesign)
          
               if strDesign && 
                  strDesign != "" && 
                  strImgFileDesign &&
                  strImgFileDesign != "" &&
                  @hhInterfaceList.has_key?(strDesign) == true
                  
                    @hhInterfaceList[strDesign].SetWindowFrame(GetImage(strImgFileDesign))
               else
              
                    Log("During setting interface frame image, invalid information was sent.")
               end
          end
           
          def self.SetInterfaceBackColor(strDesign, nColorNumber = nil)
          
               if strDesign && 
                  strDesign != "" && 
                  (!nColorNumber || 
                   (nColorNumber.is_a?(Fixnum) == true))
                  @hhInterfaceList.has_key?(strDesign) == true
                  
                    @hhInterfaceList[strDesign].SetWindowBackColor(nColorNumber)
               else
              
                    Log("During setting interface frame color, invalid information was sent.")
               end
          end 
          
          def self.SetInputButtonWindowFrame(strDesign, 
                                             strCompDesign, 
                                             strImgFileDesign)
          
               if strDesign && 
                  strDesign != "" && 
                  strCompDesign && 
                  strCompDesign != "" &&
                  strImgFileDesign && 
                  strImgFileDesign != "" &&
                  @hhInterfaceList.has_key?(strDesign) == true
                  
                    @hhInterfaceList[strDesign].SetInputButtonFrame(strCompDesign, GetImage(strImgFileDesign))
               else
              
                    Log("During setting interface input or button frame image, invalid information was sent.")
               end
          end
          
          def self.SetInputButtonBackColor(strDesign, 
                                           strCompDesign, 
                                           nColor = nil)
          
               if strDesign && 
                  strDesign != "" && 
                  strCompDesign && 
                  strCompDesign != "" &&
                  @hhInterfaceList.has_key?(strDesign) == true
                  
                    @hhInterfaceList[strDesign].SetInputButtonBackColor(strCompDesign, nColor)
               else
              
                    Log("During setting interface input or button background color, invalid information was sent.")
               end
          end
               
          def self.InputButtonProcess
               
          #          boolNotKeyFound = true    # Indicator That Pressed Key was not Found
              boolCheckInput = true     # Indicator to Check Inputs
          #          astrButtons = nil         # List of Button Designation That Has Mouse Over Them
          #          astrInButtons = []        # List of Button Designation Where Mouseover Event Is New
          #          astrOverButtons = nil     # List of Button Designation Per Selected Interface Where Mouseover Event Is Old
          #          astrClickButtons = []     # List of Button Designation Where MouseClick Event Has Happened
          #          nMouseXPos = aMousePos[0] # X-Position of Mouse Cursor
          #          nMouseYPos = aMousePos[1] # Y-Position of Mouse Cursor
          #          boolMouseClick = MouseClick(0) || MouseClick(1)
                                          # Indicator That Left or Right Mouse Click Has Happened
              
              # Check If Same Key Has Already Been Pressed to Not to Have Accidentically Repeat
              if @strLastInputLetter && @strLastInputLetter != ""
          
                   if ((@strLastInputLetter.length == 1 && KeyPress(@strLastInputLetter) == true) ||
                       (@strLastInputLetter == "ENTER" && KeyEnterPress() == true) ||
                       (@strLastInputLetter == "SPACE" && KeySpacePress() == true) ||
                       (@strLastInputLetter == "BACK" && KeyBackPress() == true) ||
                       (@strLastInputLetter == "TAB" && KeyTabPress() == true) ||
                       (@strLastInputLetter == "SHIFT" && KeyShiftPress() == true) ||
                       (@strLastInputLetter == "PERIOD" && KeyPeriodPress() == true)) && 
                      (Time.now - @tmInputLast).to_f * 1000 < @fInputPauseLimitSec * 1000
          
                        boolCheckInput = false   
                   else
                        
                        @strLastInputLetter = ""
                   end
              elsif !@strLastInputLetter && (Time.now - @tmInputLast).to_f * 1000 < @fInputPauseLimitSec * 1000
                
                   boolCheckInput = false  
              end
              
              if boolCheckInput == true
          
                   boolNotKeyFound = true
                   
                   # Check for Normal Key Input
                   @hKeyList.each { |strKeySelect, hFuncInfo|
                    
                        if hFuncInfo && KeyPress(strKeySelect.upcase) == true
          
                           hKeyInfo = hFuncInfo.clone
                           
                           if @boolUseShiftKeyUpcase == true && 
                              strKeySelect == hKeyInfo["VALUE"] &&
                              KeyShiftPress() == true
                              
                                if /[a-zA-Z]/.match(hKeyInfo["VALUE"])
                                
                                     hKeyInfo["VALUE"] = hKeyInfo["VALUE"].upcase
                                else
                                     
                                     hKeyInfo["VALUE"] = @hSpecialChars[hKeyInfo["VALUE"].to_i()]
                                end
                           end
                           
                           FuncExecute(hKeyInfo)
                           @strLastInputLetter = strKeySelect.upcase
                           boolNotKeyFound = false
                           break
                        end
                   }
          
                   # Check If Bars Were Pressed 
                   if boolNotKeyFound == true 
                        
                        if @hBarList['ENTER'] && KeyEnterPress() == true
                                                     
                            FuncExecute(@hBarList['ENTER'])
                            @strLastInputLetter = "ENTER"
                            boolNotKeyFound = false
                        elsif @hBarList['SPACE'] && KeySpacePress() == true
                                                    
                            FuncExecute(@hBarList['SPACE'])
                            @strLastInputLetter = "SPACE"
                            boolNotKeyFound = false
                        elsif @hBarList['BACK'] && KeyBackPress() == true
                                                    
                            FuncExecute(@hBarList['BACK'])
                            @strLastInputLetter = "BACK"
                            boolNotKeyFound = false
                       elsif @hBarList['TAB'] && KeyTabPress() == true
                                                    
                            FuncExecute(@hBarList['TAB'])
                            @strLastInputLetter = "TAB"
                            boolNotKeyFound = false
                       elsif @hBarList['SHIFT'] && KeyShiftPress() == true
                                      
                            FuncExecute(@hBarList['SHIFT'])
                            @strLastInputLetter = "SHIFT"
                            boolNotKeyFound = false
                       elsif @hBarList['PERIOD'] && KeyPeriodPress() == true
                                       
                            FuncExecute(@hBarList['PERIOD'])
                            @strLastInputLetter = "PERIOD"
                            boolNotKeyFound = false
                       end
                  end
          
                  if boolNotKeyFound == false
                   
                       # Set Time to Stop from Getting Repeated Keys
                       @tmInputLast = Time.now
                  end
              end
              
              aMousePos = MousePos()
              
              if aMousePos
                
          #             haInButtons = {'BUTTONS' => [], 'LISTS' => {}}
          #             haClickButtons = {'BUTTONS' => [], 'LISTS' => {}}
          #             haOverButtons = nil
                  nMouseXPos = aMousePos[0]
                  nMouseYPos = aMousePos[1]
                  nMouseClickType = -1
          #             giSelect = @hhInterfaceList[strDesign]
                  
                  if MouseLeftClick() == true
                       
                       nMouseClickType = 0
                  elsif MouseRightClick() == true
          
                       nMouseClickType = 1
                  end
                  
                  if @spMouse
                          
                       if @spMouse.x != nMouseXPos + @anMouseOffset[0] ||
                          @spMouse.y != nMouseYPos + @anMouseOffset[1] ||
                          @spMouse.z != @anMouseOffset[2] ||
                          @spMouse.angle != @anMouseOffset[3]
                          
                            @spMouse.x = nMouseXPos + @anMouseOffset[0]
                            @spMouse.y = nMouseYPos + @anMouseOffset[1]
                            @spMouse.z = @anMouseOffset[2]
                            @spMouse.angle = @anMouseOffset[3]
                            @spMouse.update
                       end
                  end
                  
                  @hhInterfaceList.each { |strDesign, giInfo|
                
                       haInButtons = {'BUTTONS' => [], 'LISTS' => {}}
                       haClickButtons = {'BUTTONS' => [], 'LISTS' => {}}
                       haOverButtons = nil
                       
                       # Get List of Buttons from Interface That Mouse Cursor is Over, 
                       # Collect in List Including Ones Clicked                
                       giInfo.FindButtonsByPos(nMouseXPos, nMouseYPos).each { |strButtonDesign|
                       
                            haInButtons['BUTTONS'].push(strButtonDesign)
                            
                            if nMouseClickType >= 0 && giInfo.IsClickable(strButtonDesign) == true
                               
                                 haClickButtons['BUTTONS'].push(strButtonDesign) 
                            end
                       }
                
                       # Get List of Buttons from Interface That Mouse Cursor is Over, 
                       # Collect in List Including Ones Clicked                
                       giInfo.FindListInputButtonByPos(nMouseXPos, nMouseYPos).each { |strListDesign, aItemDesigns|
          
                            haInButtons['LISTS'][strListDesign] = aItemDesigns
                            
                            if nMouseClickType >= 0
                               
                                 haClickButtons['LISTS'][strListDesign] = aItemDesigns
                            end
                       }
                       
                       # Button Designation Not in Prevously Mouseover Event List, Register Mouse In Event, and
                       # Button Designation in Prevously Mouseover Event List That Aren't in New One, Register Mouse Out Event
                       if @haButtonInList.has_key?(strDesign) == true
          
                            giSelect = @hhInterfaceList[strDesign]
                            haOverButtons = @haButtonInList[strDesign]
                            
                            haInButtons['BUTTONS'].each { |strButtonDesign|
                  
                                 if haOverButtons['BUTTONS'].include?(strButtonDesign) == false
                                      
                                      MouseInSend(strDesign, strButtonDesign)
                                 end
                            }
          
                            haInButtons['LISTS'].each { |strListDesign, aItemDesigns|
                              
                                   if haOverButtons['LISTS'].has_key?(strListDesign) == false 
                                        
                                        aItemDesigns.each { |strItemDesign|
                                             
                                             giSelect.GetListInputButton(strListDesign, strItemDesign).CallMouseInFuncs()
                                        }
                                   else
          
                                        aItemDesigns.each { |strItemDesign|
                                           
                                           if haOverButtons['LISTS'][strListDesign].include?(strItemDesign) == false
                                           
                                                giSelect.GetListInputButton(strListDesign, strItemDesign).CallMouseInFuncs()
                                           end
                                        }
                                   end
                            }
                            
                            haOverButtons['BUTTONS'].each { |strButtonDesign|
                       
                                 if haInButtons['BUTTONS'].include?(strButtonDesign) == false &&
                                    giSelect.CheckCompExists(strButtonDesign, 4) == true
                                      
                                      MouseOutSend(strDesign, strButtonDesign)
                                 end
                            }
          
                            haOverButtons['LISTS'].each { |strListDesign, aItemDesigns|
                                 
                                aItemDesigns.each { |strItemDesign|
                                     
                                     if giSelect.CheckListItemExists(strListDesign, strItemDesign) == true && 
                                        (haInButtons['LISTS'].has_key?(strListDesign) == false ||
                                         haInButtons['LISTS'][strListDesign].include?(strItemDesign) == false)
                                               
                                         giSelect.GetListInputButton(strListDesign, strItemDesign).CallMouseOutFuncs()
                                     end
                                }
                            }
                       end  
          
                       # Set New Mouseover List for Next Check
                       @haButtonInList[strDesign] = haInButtons
                       
                       # Do Mouse Click Event
                       haClickButtons['BUTTONS'].each { |strButtonDesign|
          
                            MouseClickSend(strDesign, strButtonDesign, nMouseClickType)
                       }
                       
                       haClickButtons['LISTS'].each { |strListDesign, aItemDesigns|
                         
                            aItemDesigns.each { |strItemDesign|
                                 
                                 giSelect.GetListInputButton(strListDesign, strItemDesign).CallMouseClickFuncs(nMouseClickType)
                            }
                       }
                    
                       if nMouseClickType == 0
                            
                            # Get List of Input from Interface That Mouse Cursor Clicked                
                            giInfo.FindInputsByPos(nMouseXPos, nMouseYPos).each { |strInputDesign|
                              
                                 if giInfo.IsClickable(strInputDesign) == true
                                 
                                      InputFocus(strDesign, strInputDesign)
                                 end
                            }
                       end
                  }
          
              end 
          end
          
          def self.ManageFollowers
               
               @hhInterfaceList.each { |strDesign, giInfo| 
               
                    giInfo.Follow()
               }
          end
          
          def self.ManageTimers
               
               ahRunner = []        # Runs Function Information from Timers
              #hTimerInfo = objTimer.clone()
                                    # Timer Info for Value Update and Function Execution 
               
               @hhTimers.delete_if { |strDesign, objTimer| 
          
                    boolRemove = false
                                    # Indicator to Remove Timer

                    if Time.now >= objTimer['START'] + objTimer['DELAY']

                         objTimer['VALUE'] = ((((Time.now - objTimer['START'] + objTimer['DELAY']) * 1000).to_f * 100) / 
                                              objTimer['LENGTH']).to_i   
                    
                         if objTimer['VALUE'] >= 100
                              
                              if (objTimer['INTERVALS'] > 0)

                                   objTimer['INTERVALS'] -= 1
                              end

                              hTimerInfo = objTimer.clone()

                              hTimerInfo['VALUE'] = hTimerInfo['PARAMS']

                              ahRunner.push(hTimerInfo)

                              if objTimer['CONTINOUS'] == true

                                   objTimer['START'] = Time.now
                              end

                              boolRemove = !(objTimer['INTERVALS'] > 0 || objTimer['CONTINOUS'] == true)
                         end
                    end
                    
                    boolRemove == true
               }
               
               ahRunner.each{ |objTimer| 
     
                    FuncExecute(objTimer)
               }
          end
          
          def self.ManageDownloads
               
               if self.const_defined?("RevCommProcessor") == true
                    
                    @ahDownloads.delete_if { |hDownload|
                         
                         boolFinished = false
                                    # Indicator That Download is Finished
                        
                         if Time.now - hDownload['START'] < hDownload['LENGTH']
 
                              if RevCommProcessor.IsConnected() == true
                                        
                                   boolFinished = RevCommProcessor.FileDownloadFinish(hDownload['DESIGNATION'], hDownload['PATH'])
                              else 
 
                                   Log('Download failed due to loss of connection during retrieval of file designation, "' + hDownload['DESIGNATION'] + '".', true)
                                   boolFinished = true
                                   
                                   RevCommProcessor.ClearStreamFileDownload(hDownload['DESIGNATION']);
                              end
                         else

                              # Else Current Download Has Exceeded Minute Time Out, Move on After Logging
                              Log('Download failed due to timeout during retrieval of file designation, "' + hDownload['DESIGNATION'] + '".', true)
                              boolFinished = true
                              
                              RevCommProcessor.ClearStreamFileDownload(hDownload['DESIGNATION']);
                         end
                         
                         boolFinished == true
                    } 
               end
          end

          def self.ManageInterfaceBars() 

               @hhInterfaceList.each { |strDesign, giInfo|
               
                    giInfo.ReDrawBars()
               }
          end
          
          def self.SetInputPauseLimitSec(fSetInputPauseLimitSec = @fInputPauseDefaultSec)
               
               if fSetInputPauseLimitSec.is_a?(Float) == true
               
                    @fInputPauseLimitSec = fSetInputPauseLimitSec
               else
             
                   Log("During setting input polling pause, invalid information was sent.")
               end
          end
          
          def self.InputMapKeyToFunc(strKey, objOwner, strFuncName, mxValue = nil)
           
               if strKey && 
                  strKey != "" &&  
                  objOwner && 
                  objOwner != "" && 
                  strFuncName && 
                  strFuncName != "" && 
                  @hKeyList.has_key?(strKey.upcase) == true
                
                   @hKeyList[strKey.upcase] = {"OBJECT" => objOwner,
                                               "METHOD" => strFuncName,
                                               "VALUE" => mxValue}
               else
             
                   Log("During mapping input key to function, invalid information was sent.")
               end
          end
          
          def self.InputMapEnterBarToFunc(objOwner, strFuncName, mxValue = nil)
           
               InputMapBarToFunc("ENTER", objOwner, strFuncName, mxValue)
           end
          
           def self.InputMapSpaceBarToFunc(objOwner, strFuncName, mxValue = nil)
            
                InputMapBarToFunc("SPACE", objOwner, strFuncName, mxValue)
           end
          
           def self.InputMapBackBarToFunc(objOwner, strFuncName, mxValue = nil)
            
                InputMapBarToFunc("BACK", objOwner, strFuncName, mxValue)
            end
           
           def self.InputMapTabBarToFunc(objOwner, strFuncName, mxValue = nil)
            
                InputMapBarToFunc("TAB", objOwner, strFuncName, mxValue)
            end
          
          def self.InputMapShiftBarToFunc(objOwner, strFuncName, mxValue = nil)
           
               InputMapBarToFunc("SHIFT", objOwner, strFuncName, mxValue)
           end

          def self.InputMapPeriodBarToFunc(objOwner, strFuncName, mxValue = nil)
           
               InputMapBarToFunc("PERIOD", objOwner, strFuncName, mxValue)
           end

          def self.InputMapBarToFunc(strType, objOwner, strFuncName, mxValue = nil)
           
                if objOwner && 
                   objOwner != "" && 
                   strFuncName && 
                   strFuncName != ""
                  
                     @hBarList[strType.upcase] = {"OBJECT" => objOwner,
                                                  "METHOD" => strFuncName,
                                                  "VALUE" => mxValue}
                else
               
                     Log("During mapping input " + strType.downcase() + " key to function, invalid information was sent.")
                end
           end
           
           def self.InputMapKeyClear(strKey)
                
                if strKey && 
                   strKey != "" &&  
                   @hKeyList.has_key?(strKey.upcase) == true
                 
                    @hKeyList[strKey.upcase] = nil
                else
              
                    Log("During clearing mapping input key, invalid information was sent.")
                end
           end
           
           def self.InputMapEnterBarClear
             
                @hBarList["ENTER"] = nil
           end
           
           def self.InputMapSpaceBarClear
             
                @hBarList["SPACE"] = nil
           end
           
           def self.InputMapBackBarClear
             
                @hBarList["BACK"] = nil
           end
           
           def self.InputMapTabBarClear
             
                @hBarList["TAB"] = nil
           end
          
           def self.InputMapShiftBarClear
             
                @hBarList["SHIFT"] = nil
           end

          def self.InputMapPeriodBarClear
            
               @hBarList["PERIOD"] = nil
          end

          def self.InputMapReset
            
               @hKeyList = {'0' => nil, '1' => nil, '2' => nil, '3' => nil, '4' => nil, 
                            '5' => nil, '6' => nil, '7' => nil, '8' => nil, '9' => nil, 
                            'E' => nil, 'A' => nil, 'R' => nil, 'I' => nil,
                            'O' => nil, 'T' => nil, 'N' => nil, 'S' => nil,
                            'L' => nil, 'C' => nil, 'U' => nil, 'D' => nil,
                            'P' => nil, 'M' => nil, 'H' => nil, 'G' => nil, 
                            'B' => nil, 'F' => nil, 'Y' => nil, 'W' => nil, 
                            'K' => nil, 'V' => nil, 'X' => nil, 'Z' => nil, 
                            'J' => nil, 'Q' => nil }
               @hBarList = {'ENTER' => nil, 'SPACE' => nil, 'BACK' => nil, 'TAB' => nil, 'SHIFT' => nil, 'PERIOD' => nil}
          end
          
          def self.InputMapDefaults(boolUseTextSpaces = false)
            
               @hKeyList.each { |strKeySelect, mxValue|
            
                   @hKeyList[strKeySelect] = {"OBJECT" => self,
                                              "METHOD" => "InputWrite",
                                              "VALUE" => strKeySelect.downcase}
               }
          
               @hBarList["ENTER"] = {"OBJECT" => self,
                                     "METHOD" => "InputSend",
                                     "VALUE" => nil}
          
               if boolUseTextSpaces == true
                    
                    @hBarList["SPACE"] = {"OBJECT" => self,
                                          "METHOD" => "InputWrite",
                                          "VALUE" => " "}
               end
          
               @hBarList["BACK"] = {"OBJECT" => self,
                                    "METHOD" => "InputDelete",
                                    "VALUE" => nil}
          
               @hBarList["TAB"] = {"OBJECT" => self,
                                   "METHOD" => "InputNextFocus",
                                   "VALUE" => nil}

               @hBarList["PERIOD"] = {"OBJECT" => self,
                                      "METHOD" => "InputWrite",
                                      "VALUE" => "."}
          end
          
          def self.MouseClick(nButtonType)
               
               return @w32Mouse.call(nButtonType) & 0x01 == 1
          end
          
          def self.MousePos()
               
               # aClickPos = [0, 0].pack('ll')      
                                    # Coordinates of Mouse
               # aScreenWidth = [0, 0, 0, 0].pack('l4')
                                    # Screen Size Information
              
               if @hWindow
                    
                    aClickPos = [0, 0].pack('ll')
                         
                    if @w32Cursor.call(aClickPos) != 0
                        
                        if @w32Screen.call(@hWindow, aClickPos) != 0
                        
                             aClickPos = aClickPos.unpack('ll')
                             
                             aScreenWidth = [0, 0, 0, 0].pack('l4')
                             
                             if @w32AppWindowInfo.call(@hWindow, aScreenWidth) == 1
                                
                                  aScreenWidth = aScreenWidth.unpack('l4')
                                  
                                  if aClickPos[0] < 0 || aClickPos[0] > aScreenWidth[2] ||
                                     aClickPos[1] < 0 || aClickPos[1] > aScreenWidth[3]
                                  
                                       aClickPos = nil  
                                     
                                  end
                                  
                             else
                                       
                                  aClickPos = nil
                             end
                        else
               
                             aClickPos = nil
                             Log('During mouse position check, getting screen information failed.', true)
                        end
                    else
               
                        aClickPos = nil
                        Log('During mouse position check, getting cursor information failed.', true)
                    end
               end
               
               return aClickPos
          end
          
          def self.GetDownloadList
               
               aStreamFileList = [] # List of Downloadable File Designation
#               strJSONMsg = RevCommProcessor.GetAvailableFileList()
                                     # List from Server as JSON Object
               
               if self.const_defined?("RevCommProcessor") == true
                    
                    # If List of Available Files for Download from Server were Collected
                    strJSONMsg = RevCommProcessor.GetAvailableFileList()
                    
                    if strJSONMsg != ''
                         
                         aStreamFileList = JSONConvert.Decode(strJSONMsg)["STREAMFILELIST"]
                    else
                         
                         Log('During getting download list, list could not be collected. If connection to RevCommServer is recent, list may be have been sent yet.')
                    end
               else
                    
                    Log('During getting download list, list could not be collected. RevCommProcessor required.')
               end
               
               return aStreamFileList

          end

          def self.DownloadAll(strFilePath = "", nDownloadTimeLimitSec = 60)
               
               nCount = 0          # Count of Downloads

               GetDownloadList().each { | strDesign | 

                    SetTimer("REVCOM-DOWNLOAD-TIMER-" + strDesign + "-" + Time.now.to_s, 
                             self, 
                             "DownloadTimerQueue",
                              nDownloadTimeLimitSec * 1000 * nCount,
                              Time.now,
                              0,
                              0,
                              false,
                              [strDesign, strFilePath, nDownloadTimeLimitSec])

                    nCount += 1
               }
          end

          def self.DownloadTimerQueue(mxInfo = [])
            
               if mxInfo.length() == 3

                    DownloadAssets(mxInfo[0], mxInfo[1], mxInfo[2])
               end
          end

          def self.DownloadUpdate(strGameName, strFilePath = "", nDownloadTimeLimitSec = 60)
               
               nMsgID = RevCommProcessor.GetUniqueID()     
                                   # Messsage ID for Sending to Data Process for File Information
               
               RevCommProcessor.AutoRetProcessCmd(true)
               RevCommProcessor.AutoRetEndTrans(true)
               RevCommProcessor.StartDataProcess(nMsgID, 'download_vers')
               RevCommProcessor.AddDataProcessParams(nMsgID, 'version', @hhBGMRPGMData["DOWNLOADER"]["VERSION"])
               RevCommProcessor.AddDataProcessParams(nMsgID, 'gamename', strGameName)
               RevCommProcessor.AddDataProcessParams(nMsgID, 'filepath', strFilePath)
               RevCommProcessor.AddDataProcessParams(nMsgID, 'timelimit', nDownloadTimeLimitSec)
                    
               if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == false
                    
                    Log('During getting download update for game: "' + strGameName + '", send failed.')
               end    
          end
          
          def self.DownloadAssets(mxFileDesigns = [], strFilePath = "", nDownloadTimeLimitSec = 60)
          
#               nMsgID = RevCommProcessor.GetUniqueID()   
                                    # Messsage ID for Sending to Data Process for File Information
               
               if self.const_defined?("RevCommProcessor") == true
                    
                    if mxFileDesigns.is_a?(Array) == false
                       
                         if mxFileDesigns.is_a?(String) == true
                            
                              mxFileDesigns = [mxFileDesigns]
                         else
                              
                              mxFileDesigns = nil
                         end
                    end
                    
                    if mxFileDesigns
                         
                         RevCommProcessor.AutoRetProcessCmd(true)
                         RevCommProcessor.AutoRetEndTrans(true)
     
                         mxFileDesigns.each { |strFileDesign|

                              nMsgID = RevCommProcessor.GetUniqueID()     
          
                              RevCommProcessor.StartDataProcess(nMsgID, 'download_info')
                              RevCommProcessor.AddDataProcessParams(nMsgID, 'design', strFileDesign)
                              RevCommProcessor.AddDataProcessParams(nMsgID, 'filepath', strFilePath)
                              RevCommProcessor.AddDataProcessParams(nMsgID, 'timelimit', nDownloadTimeLimitSec)
                                   
                              if RevCommProcessor.SendDataProcess(nMsgID, RevCommProcessor.GetUniqueID()) == false
                                   
                                   Log('During getting download asset, "' + strFileDesign + '", send failed.')
                              end    
                         }
                    else
     
                         Log('During starting asset download, file designation or list of designations was invalid.')
                    end
               end
          end

          def self.DownloadStart(strFileDesign, 
                                 strFileType = nil, 
                                 strFilePath = nil,
                                 nDownloadTimeLimitSec = 60)
                                 
#               hFileTypes = {}     # Files Types and File Pathes
          
               if self.const_defined?("RevCommProcessor") == true
           
                    if strFileType && (!strFilePath || strFilePath == "")
     
                        hFileTypes = {'AUDIO_BGM' => 'Audio\\BGM\\',
                                      'AUDIO_BGS' => 'Audio\\BGS\\',
                                      'AUDIO_ME' => 'Audio\\ME\\',
                                      'AUDIO_SE' => 'Audio\\SE\\',
                                      'GRAPHICS_ANIMATIONS' => 'Graphics\\Animations\\',
                                      'GRAPHICS_BATTLEBACKS1' => 'Graphics\\Battlebacks1\\',
                                      'GRAPHICS_BATTLEBACKS2' => 'Graphics\\Battlebacks2\\',
                                      'GRAPHICS_BATTLERS' => 'Graphics\\Battlers\\',
                                      'GRAPHICS_CHARACTERS' => 'Graphics\\Characters\\',
                                      'GRAPHICS_FACES' => 'Graphics\\Faces\\',
                                      'GRAPHICS_PARALLAXES' => 'Graphics\\Parallaxes\\',
                                      'GRAPHICS_PICTURES' => 'Graphics\\Pictures\\',
                                      'GRAPHICS_SYSTEM' => 'Graphics\\System\\',
                                      'GRAPHICS_TILESETS' => 'Graphics\\Tilesets\\',
                                      'GRAPHICS_TITLES1' => 'Graphics\\Titles1\\',
                                      'GRAPHICS_TITLES2' => 'Graphics\\Titles2\\',
                                      'DATA' => 'Data\\'}
                        
                        if !(strFilePath = hFileTypes[strFileType])
                                        
                              strFilePath = ""
                        end

                    else
                         
                         strFilePath.gsub!('/', '\\')
                    
                         if strFilePath[-1] != '\\'
                        
                              strFilePath += '\\'
                         end
                    end
                    
                    RevCommProcessor.FileDownloadStart(strFileDesign)
                    
                    @ahDownloads.push({'DESIGNATION' => strFileDesign,
                                       'PATH' => strFilePath,
                                       'START' => Time.now,
                                       'LENGTH' => nDownloadTimeLimitSec})

               end
          end
          
          # Save Game Data 
          def self.SaveGameData
               
               strFileAccessMode = "wb"
                                    # Type of File Access
               hhSave = nil         # Holder for Save Data
               
               @hhBGMRPGMData["SETTINGS"] = @hhSettings
               @hhBGMRPGMData["IMAGES"] = @hhImages

               hhSave = @hhBGMRPGMData.clone
                    
               hhSave["IMAGES"].each{ |strImgDesign, hImgInfo|
                    
                    if hImgInfo["BITMAP"]
                    
                         hImgInfo["BITMAP"].dispose()
                         hImgInfo["BITMAP"] = nil
                    end
               }
               
               if File.file?(@strDataFilePath) == false
                    
                    strFileAccessMode = "w+b"
               end
                    
               File.open(@strDataFilePath, strFileAccessMode) do |flSave|
                    Marshal.dump(hhSave, flSave)
               end
          end

          def self.Log(strMsg, boolError = false)
             
     #          tmCurrent = Time.now # Current Time
     #          fLog = nil           # Log File
               
               if self.const_defined?("RevCommProcessor") == true
               
                    RevCommProcessor.Log(strMsg, boolError)
               else
                    
                    if !@mtxLock
               
                         @mtxLock = Mutex.new
                    end
                    
                    @mtxLock.lock()
      
                    tmCurrent = Time.now
                    fLog = nil      
                            
                    begin
                    
                        if File.directory?("Logs") == false
                  
                              Dir.mkdir("Logs")
                  
                        end
                  
                        fLog = File.open("Logs/Log-" + tmCurrent.strftime("%Y%m%d") + ".txt", 'a')
                        
                        if boolError
                              
                              strMsg = 'ERROR - ' + strMsg
                                
                        end
                  
                        fLog.write(tmCurrent.strftime("%H:%M:%S.%L") + ": " + strMsg + "\n")
           
                   
                    rescue Exception => exError
                       
                        raise("Error: Writing to log file failed. Message: " + exError.message)
                  
                    ensure
                  
                        fLog.close unless fLog == nil
                        
                    end
              
                    @mtxLock.unlock()
                    
               end
          end

          def self.Close

               if self.const_defined?("RevCommProcessor") == true
               
                    RevCommProcessor.Disconnect()
               end               
               
               RemoveMouseImage()  
               
               @hhInterfaceList.each { |strDesignSelect, giInterface|
          
                    giInterface.Clear()
               }
                    
               @hhBGMRPGMData["IMAGES"].each{ |strImgDesign, hImgInfo|
     
                    if hImgInfo["BITMAP"]

                         hImgInfo["BITMAP"].dispose()
                         hImgInfo["BITMAP"] = nil
                    end
               }
               
               if @thdDownload != nil
                   
                   @thdDownload.join()
                   @thdDownload = nil
               
               end
          end
end

RevComEngine_Core = BGMRPGM_Core

# Base for Interactive Classes
class BGMRPGM_Base < Window_Base

     alias :doDrawText draw_text     # Alias for Window_Base draw_text Method
     alias :doTextSize text_size     # Alias for Window_Base text_size Method
     alias :doDisposed disposed?     # Alias for Window_Base disposed? Method
     alias :doDispose dispose        # Alias for Window_Base dispose Method
     
#     @nXPos = nSetXPos              # X-Axis Position
#     @nYPos = nSetYPos              # Y-Axis Position
#     @nWidth = nSetWidth            # Width of Dialog
#     @nHeight = nSetHeight          # Height of Dialog
#     @cBackColor                    # Background Color
#     @mtxLock = Mutex.new           # Lock for Thread
#     @boolDisposed = false          # Indicator That Window was Disposed
     
     def initialize(nSetXPos, nSetYPos, nSetWidth, nSetHeight)
          
          @nXPos = nSetXPos
          @nYPos = nSetYPos
          @nWidth = nSetWidth
          @nHeight = nSetHeight
          @cBackColor = GetDefaultWindowColor()
          @mtxLock = Mutex.new
          @boolDisposed = false
          
          super(nSetXPos, nSetYPos, nSetWidth, nSetHeight)
     end   
     
     def SetWindowFrame(bmImage = nil)
       
          self.windowskin = bmImage
          
          if bmImage

               width = bmImage.width
               height = bmImage.height
          end
          
          create_contents()
     end 
  
     def SetWindowBackColor(nColor = nil)
      
          if nColor

               @cBackColor = text_color(nColor)
          else
               
               @cBackColor = GetDefaultWindowColor()
          end
          
          update_tone()
     end  

     def SetFont(mxFontNames, aColorValues = nil, boolShadow = false) 
          
          boolSet = false           # Indicator Font was Sent
          
          if mxFontNames.is_a?(String) == true
               
               mxFontNames = [mxFontNames]
          end
          
          if mxFontNames.is_a?(Array) == true
          
               contents.font.name = mxFontNames
               boolSet = true
          end

          if aColorValues.is_a?(Array) == true && aColorValues.length >= 4
          
               contents.font.color = Color.new(aColorValues[0], aColorValues[1], aColorValues[2], aColorValues[3])
          end
          
          contents.font.shadow = boolShadow
          
          Draw()
          
          return boolSet
     end
     
     def SetFontSize(nSize, boolBold = Font.default_bold) 
          
          contents.font.size = nSize
          contents.font.bold = boolBold
          
          Draw()
     end

     def IsInBounds?(nXCheckPos, nYCheckPos, nCheckWidth = @nWidth, nCheckHeight = @nHeight)
          
          return  @nXPos <= nXCheckPos &&
                  @nYPos <= nYCheckPos &&
                  @nXPos + nCheckWidth >= nXCheckPos &&
                  @nYPos + nCheckHeight >= nYCheckPos
     end
     
     def GetDefaultWindowColor
          
          clrDefault = nil          # Default Window Color
          
          if $game_system
               
               clrDefault = $game_system.window_tone
          else
               
               clrDefault = Color.new(-34, 0, 68, 0)
          end
          
          return clrDefault
     end

     def update_tone
  
          self.tone.set(@cBackColor)
     end
     
     # Used to be Replaced By Inherited Classes
     def Draw 
     end

     def draw_text(nXPos, nYPos, nWidth, nHeight, strText)

          if disposed?() == false
          
               doDrawText(nXPos, nYPos, nWidth, nHeight, strText)
          end
     end

     def text_size(strText)

          rectSizeInfo = Rect.new(0, 0, 0, 0)

          if disposed?() == false
          
               rectSizeInfo = doTextSize(strText)
          end

          return rectSizeInfo
     end

     def dispose

          @boolDisposed = true

          doDispose
     end

     def disposed?

          if @boolDisposed == false

               @boolDisposed = doDisposed()
          end

          return @boolDisposed
     end
end

# Input Box
class BGMRPGM_Input < BGMRPGM_Base
     
#     @strDefaultText = ""           # Default Text to Display
#     @strAddedText = ""             # Text to be Added to Display
#     @nDefaultCharLimit = 10        # Default Text Character Limit 
#     @nAddedCharLimit = 25          # Added Text Character Limit
#     @boolClearOnGetText = false    # Indicator to Clear Text After Getting Text
#     @boolGetAllText = false        # Indicator to Get All Text
#     @boolClearDefault = false      # Indicator to Clear Default with Added
#     @ahDestFuncInfo = []           # List of Objects and Functions to Call with Text Values
#     @ahMouseInFuncInfo = []        # List of Objects and Functions to Call During Mouse Contact with Text Values
#     @ahMouseOutFuncInfo = []       # List of Objects and Functions to Call During Mouse Loss of Contact with Text Values
#     @ahMouseClickFuncInfo = []     # List of Objects and Functions to Call During Mouse Click with Text Values
#     @ahMouseEventQueue = []        # List of Objects and Functions from Mouse Events to Execute 
#     @rcCursor  = cursor_rect       # Window's Cursor
#     @boolVisible = true            # Indicator to Show Interface
#     @boolShowCursor = false        # Indicator to Show Text Cursor
#     @nSendType = 0                 # Send Type Indicator - 0 for Default Which Text for Input and Object for Buttons, 1 for Text, 2 for Object
#     @nTextType = 0                 # Text Type Indicator - 0 for Default Which Text for All Send Text, 1 for Letters Only, 2 for Numbers Only
#     @nMinValue = nil               # Minimum Numerical Value That Can Be Entered
#     @nMaxValue = nil               # Maximum Numerical Value That Can Be Entered
#     @boolAllowSpaces = false       # Indicator To Allow Spaces in Text
#     @boolIsNotPrivate = true       # Indicator That Input Holds Private Data
     
     def initialize(nSetXPos, nSetYPos, nSetWidth, nSetHeight)
      
          @cBackColor = GetDefaultWindowColor()
          @strDefaultText = "" 
          @strAddedText = ""    
          @nDefaultCharLimit = 10
          @nAddedCharLimit = 25                 
          @boolClearOnGetText = false  
          @boolGetAllText = false       
          @boolClearDefault = false    
          @ahDestFuncInfo = []     
          @ahMouseInFuncInfo = []     
          @ahMouseOutFuncInfo = []     
          @ahMouseClickFuncInfo = []  
          @ahMouseEventQueue = []   
          @boolVisible = true
          @boolShowCursor = false  
          @nSendType = 0  
          @nTextType = 0 
          @nMinValue = nil 
          @nMaxValue = nil
          @boolAllowSpaces = false
          @boolIsNotPrivate = true 
          
          super(nSetXPos, nSetYPos, nSetWidth, nSetHeight)
          
          @rcCursor = cursor_rect

          Draw()
     end     
     
     def SetDefaultText(strSetText)

          if strSetText.length <= @nDefaultCharLimit
          
               @strDefaultText = strSetText
          else
               
               @strDefaultText = strSetText[0, @nDefaultCharLimit]
          end

          Draw()
     end
     
     def SetFuncCall(objDestination, strMethodName)
          
         boolSet = false            # Indicator That Function Call was Set
         
         if objDestination && 
            strMethodName &&
            strMethodName != ""
            
             @ahDestFuncInfo.push({"OBJECT" => objDestination,
                                   "METHOD" => strMethodName,
                                   "VALUE" => nil}) 
             boolSet = true
         else
           
             BGMRPGM_Core.Log("During setting input send functions, invalid values was sent.")
         end
         
         return boolSet
     end 

     def SetMouseInFuncCall(objDestination, strMethodName)
           
          boolSet = false            # Indicator That Function Call was Set
          
          if objDestination && 
             strMethodName &&
             strMethodName != ""

              @ahMouseInFuncInfo.push({"OBJECT" => objDestination,
                                       "METHOD" => strMethodName,
                                       "VALUE" => nil}) 
              boolSet = true
          else
            
              BGMRPGM_Core.Log("During setting input send functions for mouse in events, invalid values was sent.")
          end
          
          return boolSet
     end 

     def SetMouseOutFuncCall(objDestination, strMethodName)
            
           boolSet = false            # Indicator That Function Call was Set
           
           if objDestination && 
              strMethodName &&
              strMethodName != ""
              
               @ahMouseOutFuncInfo.push({"OBJECT" => objDestination,
                                         "METHOD" => strMethodName,
                                         "VALUE" => nil}) 
               boolSet = true
           else
             
               BGMRPGM_Core.Log("During setting input send functions for mouse out events, invalid values was sent.")
           end
           
           return boolSet
     end 

     def SetMouseClickFuncCall(objDestination, strMethodName, nClickType = 0)
             
          boolSet = false            # Indicator That Function Call was Set
            
          if objDestination && 
             strMethodName &&
             strMethodName != ""
               
                @ahMouseClickFuncInfo.push({"OBJECT" => objDestination,
                                            "METHOD" => strMethodName,
                                            "VALUE" => nil,
                                            "TYPE" => nClickType}) 
                boolSet = true
          else
              
               BGMRPGM_Core.Log("During setting input send functions for mouse click events, invalid values was sent.")
          end
            
          return boolSet
     end 
     
     def AddText(strSetText, boolAddSpaceBefore = false)

          if @strAddedText.length < @nAddedCharLimit &&
             (@nTextType == 0 || 
              (@nTextType == 1 && 
               (/[a-zA-Z]/.match(strSetText) || 
                (@strAddedText == " " && @boolAllowSpaces == true))) ||
              (@nTextType == 2 && /[0-9]/.match(strSetText) && 
               ((!@nMinValue || (@nMinValue <= (@strAddedText + strSetText).to_i)) && 
                (!@nMaxValue || (@nMaxValue >= (@strAddedText + strSetText).to_i)))))
               
               if @strAddedText != "" && boolAddSpaceBefore == true
                    
                    strSetText = " " + strSetText
               end
               
               if (@strAddedText + strSetText).length <= @nAddedCharLimit
               
                    @strAddedText = @strAddedText + strSetText
               else

                    @strAddedText = @strAddedText + strSetText[0, @nAddedCharLimit - @strAddedText.length]
               end
     
               Draw()
          end
     end 
     
     def DeleteText(boolLastWord = false)
          
          if boolLastWord == true
              
               if @strAddedText.rindex(" ")
               
                    @strAddedText = @strAddedText[0, @strAddedText.rindex(" ")]
               else
                    
                    @strAddedText = ""
               end
          elsif @strAddedText.length > 1
               
               @strAddedText = @strAddedText[0, @strAddedText.length - 1]
          else
               
               @strAddedText = ""
          end

          Draw()
     end
     
     def GetText(boolClearText = false)
        
          strText = @strAddedText   # Text to Return
       
          if @boolGetAllText == true  
               
               strText = @strDefaultText + strText
          end
          
          if boolClearText == true || @boolClearOnGetText == true
               
               ClearText()
          end
          
          return strText
     end

     def ClearText
        
          @strAddedText = ""
          
          if @boolClearDefault == true
               
               @strDefaultText = ""
          end
          
          Draw()
     end

     def ResetText
        
          strText = GetText()       # Text to Return
          
          ClearText()
          
          return strText
     end

     def SetMinNumValue(nSetValue = nil)

          boolSet = false           # Indicator That Value was Set
          
          if @nTextType == 2 && 
             (!nSetValue || /[0-9]/.match(nSetValue.to_s))
              
               @nMinValue = nSetValue
               boolSet = true
          end
          
          return boolSet
     end
     
     def SetMaxNumValue(nSetValue = nil)

          boolSet = false           # Indicator That Value was Set

          if @nTextType == 2 && 
             (!nSetValue || /[0-9]/.match(nSetValue.to_s))
              
               @nMaxValue = nSetValue
               boolSet = true
          end
          
          return boolSet
     end

     def SetPos(nSetXPos, nSetYPos)

          if @nXPos != nSetXPos || @nYPos != nSetYPos
               
               @nXPos = nSetXPos
               @nYPos = nSetYPos
               self.x = nSetXPos
               self.y = nSetYPos
               Draw()
          end
     end
     
     def CallFuncs 

          mxValue = nil        # Value to Return
          
          if @nSendType < 2

               mxValue = GetText(true) 
          elsif @nSendType == 2
               
               mxValue = self
          end
          
          @ahDestFuncInfo.each { |hDestSelect|
          
               hDestSelect["VALUE"] = mxValue
                 
               @ahMouseEventQueue.push(hDestSelect.clone)
          }
     end

     def CallMouseInFuncs 

          mxValue = self        # Value to Return
          
          if @nSendType == 1

               mxValue = GetText()
          elsif @nSendType > 2
               
               mxValue = nil
          end
          
          CallFuncs()
           
          @ahMouseInFuncInfo.each { |hDestSelect|
           
              hDestSelect["VALUE"] = mxValue
                 
              @ahMouseEventQueue.push(hDestSelect.clone)
          }
     end

     def CallMouseOutFuncs 

          mxValue = self        # Value to Return
          
          if @nSendType == 1

               mxValue = GetText()
          elsif @nSendType > 2
               
               mxValue = nil
          end
          
          CallFuncs()
            
          @ahMouseOutFuncInfo.each { |hDestSelect|
            
              hDestSelect["VALUE"] = mxValue
                  
              @ahMouseEventQueue.push(hDestSelect.clone)
          }
     end

     def CallMouseClickFuncs(nClickType = 0)

          mxValue = self        # Value to Return
          
          if @nSendType == 1

               mxValue = GetText()
          elsif @nSendType > 2
               
               mxValue = nil
          end
          
          CallFuncs()
           
          @ahMouseClickFuncInfo.each { |hDestSelect|
           
               if hDestSelect["TYPE"] == nClickType
              
                    hDestSelect["VALUE"] = mxValue
      
                    @ahMouseEventQueue.push(hDestSelect.clone)
               end
          }
     end
     
     def DequeueEventFuncs
          
          ahMouseEvents = @ahMouseEventQueue.clone
          @ahMouseEventQueue = []
          
          return ahMouseEvents
     end
     
     def ClearFuncs
           
           @ahDestFuncInfo = [] 
           @ahMouseInFuncInfo = []     
           @ahMouseOutFuncInfo = []     
           @ahMouseClickFuncInfo = []   
     end
     
     def Show(boolSetVisible = true)
          
          @boolVisible = boolSetVisible
          
          if boolSetVisible == true
               
               self.opacity = 255
          else
               
               self.opacity = 0
          end
          
          Draw()
     end
     
     def ShowCursor(boolShow)
          
          if boolShow.nil? == false
               
               @boolShowCursor = boolShow
               Draw() 
          end
          
          return @boolShowCursor
     end
     
     def Count
          
          return @strAddedText.length
     end

     def IsVisible
          
          return @boolVisible
     end
     
     # Set to Have Input Return Label Text Added to Entered Text When its Input Value is Retrieved
     def SetGetAllText(boolSetGetAllText = false)
          
          if boolSetGetAllText.is_a?(TrueClass) || boolSetGetAllText.is_a?(FalseClass)
               
               @boolGetAllText = boolSetGetAllText
          end
     end

     # Set to Have the Input Label Cleared When Entered Text is Cleared When its Input Value is Retrieved
     def SetClearDefault(boolSetClearDefault = false)
          
          if boolSetClearDefault.is_a?(TrueClass) || boolSetClearDefault.is_a?(FalseClass)
               
               @boolClearDefault = boolSetClearDefault
          end
     end

     # Set to Have Input's Entered Text Cleared When its Input Value is Retrieved
     def SetClearOnGetText(boolSetClearOnGetText = false)
          
          if boolSetClearOnGetText.is_a?(TrueClass) || boolSetClearOnGetText.is_a?(FalseClass)
               
               @boolClearOnGetText = boolSetClearOnGetText
          end
     end

     # Set Default Character Limit for Input Value That Can be Entered
     def SetAddedCharLimit(nSetAddedCharLimit = 25)
          
          if nSetAddedCharLimit.is_a?(Fixnum) == true && nSetAddedCharLimit > 0
               
               @nAddedCharLimit = nSetAddedCharLimit
          end
     end

     # Set Character Label Limit for Input
     def SetDefaultCharLimit(nSetDefaultCharLimit = 10)
          
          if nSetDefaultCharLimit.is_a?(Fixnum) == true && nSetDefaultCharLimit >= 0
               
               @nDefaultCharLimit = nSetDefaultCharLimit
          end
     end

     # Set Option Type for Sending Entered Text 
     # Send Type Indicator - 0 for Default Which Text for Input and Object for Buttons, 1 for Text, 2 for Object
     def SetSendType(nSetSendType = 0)
          
          if nSetSendType.is_a?(Fixnum) == true && nSetSendType >= 0
               
               @nSendType = nSetSendType
          end
     end

     # Set Option for Type of Text That Can be Entered  
     # Text Type Indicator - 0 for Default Which Text for All Send Text, 1 for Letters Only, 2 for Numbers Only
     def SetTextType(nSetTextType = 0)
          
          if nSetTextType.is_a?(Fixnum) == true && nSetTextType >= 0
               
               @nTextType = nSetTextType
          end
     end

     # Set to Allow the Entry of Spaces in When Entering Alphanumeric Text
     def SetAllowSpaces(boolSetAllowSpaces = false)
          
          if boolSetAllowSpaces.is_a?(TrueClass) || boolSetAllowSpaces.is_a?(FalseClass)
               
               @boolAllowSpaces = boolSetAllowSpaces
          end
     end
     
     def SetPrivate(boolSetIsPrivate = false)
          
          if (boolSetIsPrivate.is_a?(TrueClass) || boolSetIsPrivate.is_a?(FalseClass)) &&
             @boolIsNotPrivate != !boolSetIsPrivate
               
               @boolIsNotPrivate = !boolSetIsPrivate
               Draw()
          end
     end
     
     private 
          
          def Draw
               
               strDisplayText = ""  # Display Text
#               rcSize = text_size(@strDefaultText + @strAddedText)
                                    # Rectangle Based on Text Size Information
#               nTextHeight = contents_height()
                                    # Height of Text
                    
               if disposed?() == false 

                    @mtxLock.lock()

                    contents.clear()
                    
                    if @boolVisible == true
          
                         if @boolIsNotPrivate == true 
          
                              strDisplayText = @strDefaultText + @strAddedText
                         else
                              
                              strDisplayText = "".rjust((@strDefaultText.length + @strAddedText.length), "*")
                         end
                         
                         rcSize = text_size(strDisplayText)
                         nTextHeight = contents_height()
                         
                         draw_text(3, 
                                   ((nTextHeight / 2) * -1) + standard_padding - 2, 
                                   contents_width(), 
                                   nTextHeight, 
                                   strDisplayText)
               
                         if @boolShowCursor == true
                              
                              @rcCursor.set(rcSize.width + 3, 0, 2, nTextHeight)
                         else
                              
                              @rcCursor.set(0, 0, 0, 0)
                         end
                    else
                         
                         @rcCursor.set(0, 0, 0, 0)
                    end

                    @mtxLock.unlock()
               end
          end
end

class BGMRPGM_Interface < BGMRPGM_Base
     
     #     @mxFollower = nil              # Following Player or Enemy 
     #     @nXFollowOffset = 0            # X-Axis Offset from Follower Position
     #     @nYFollowOffset = 0            # Y-Axis Offset from Follower Position
     #     @nMode = 0                     # Interface Mode: 0 - Normal, 1 - Blinking, 2 - Faded
     #     @boolVisible = true            # Indicator to Show Interface
     #     @boolUpdated = false           # Indicator to Update Components
     #     @thdBlink = nil                # Thread for Controlling Blinking of Interface
     #     @nBlinkDurationSecs = 5        # Total Duration of Blink
     #     @fBlinkIntervalSecs = 0.25     # Interval of Blinking
     
     def initialize(nSetXPos, nSetYPos, nSetWidth, nSetHeight, nSetMode = 0)

          @hhComponents = {} 
          @mxFollower = nil    
          @nXFollowOffset = 0          
          @nYFollowOffset = 0       
          @nMode = nSetMode 
          @boolVisible = true
          @boolUpdated = false
          @thdBlink = nil    
          @nBlinkDurationSecs = 5
          @fBlinkIntervalSecs = 0.25

          super(nSetXPos, nSetYPos, nSetWidth, nSetHeight) 
          
          SetMode(nSetMode)
     end
     
     def AddText(strDesign, strText, nXOffset = 0, nYOffset = 0) 
          
          boolAdded = false         # Indicator That Text was Added
          
          if strDesign && 
             strDesign != "" && 
             strText

               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset)
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign)
                    end
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 0,
                                                'TEXT' => strText,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset}
                    ReDraw()
                                          
                    boolAdded = true
               else
                 
                    BGMRPGM_Core.Log("During adding interface text, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end
          else
             
               BGMRPGM_Core.Log("During adding interface text to interface, invalid information was sent.")
          end
          
          return boolAdded
     end

     def AddBar(strDesign, 
                nXOffset, 
                nYOffset, 
                nWidth, 
                nHeight = 15, 
                nType = 0, 
                nValue = 0, 
                nLimit = 100, 
                nColorBar = 0, 
                nColorBack = 19,
                fTimeLimitInMillis = 5000) 
          
          boolAdded = false         # Indicator That Bar was Added
          
          if strDesign && 
             strDesign != ""
             
               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset) == true
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign)
                    end
                    
                    if nHeight < 15
                         
                         nHeight = 15  
                    end
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 1,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset,
                                                'WIDTH' => nWidth,
                                                'HEIGHT' => nHeight,
                                                'COLORFOREGROUND' => text_color(nColorBar),
                                                'COLORBACKGROUND' => text_color(nColorBack),
                                                'TYPE' => nType, 
                                                'VALUE' => nValue, 
                                                'LIMIT' => nLimit,
                                                'TIME' => fTimeLimitInMillis,
                                                'START' => Time.now,
                                                'SHOW' => true}
                                                
                    case nType
                         
                         when 0
                         
                              boolAdded = true
                         
                         when 1
                              
                              @hhComponents[strDesign]['VALUE'] = 0
                              @hhComponents[strDesign]['SHOW'] = false
                              boolAdded = true
                                   
                         when 2
                              
                              if @hhComponents[strDesign]['TIME'] <= 0
     
                                   @hhComponents[strDesign]['SHOW'] = false
                              end
     
                              boolAdded = true
                         else
                     
                              @hhComponents.delete(strDesign)
                              BGMRPGM_Core.Log("During adding interface bar, invalid type, " + nType.to_s + ", was sent.")
                    end

                    if boolAdded == true

                         ReDraw()
                    end
               else
                 
                    BGMRPGM_Core.Log("During adding interface bar, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end

          else
             
               BGMRPGM_Core.Log("During adding bar to interface, invalid information was sent.")
          end
          
          return boolAdded
     end

     def AddInput(strDesign, nXOffset, nYOffset, nWidth, nHeight, strDefaultText = nil, boolDispose = true) 
          
          gdInput = nil             # Newly Created Input
          
          if strDesign && 
             strDesign != ""
     
               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset) == true
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign, boolDispose)
                    end
                    
                    gdInput = BGMRPGM_Input.new(@nXPos + nXOffset, @nYPos + nYOffset, nWidth, nHeight)
                    
                    if strDefaultText &&
                       strDefaultText != ""
                         
                         gdInput.SetDefaultCharLimit(strDefaultText.length)
                         gdInput.SetDefaultText(strDefaultText)
                    end
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 2,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset,
                                                'INPUT' => gdInput,
                                                'CLICKABLE' => true}

                    ReDraw()
               else
              
                    BGMRPGM_Core.Log("During adding interface input, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end
          else
              
                BGMRPGM_Core.Log("During adding interface input, invalid information was sent.")
          end
          
          return gdInput
     end

     def AddList(strDesign, nXOffset, nYOffset, nItemWidth, nItemHeight, nOffsetType = 0, boolDispose = true)
         
          boolAdded = false         # Indicator That List was Added
          
          if strDesign && 
             strDesign != ""
               
               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset) == true
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign, boolDispose)
                    end
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 3,
                                                'TYPE' => nOffsetType,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset,
                                                'ITEMWIDTH' => nItemWidth,
                                                'ITEMHEIGHT' => nItemHeight,
                                                'ITEMS' => {}}

                    ReDraw()
                                                     
                    boolAdded = true
               else
                 
                    BGMRPGM_Core.Log("During adding interface list, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end
          else
             
               BGMRPGM_Core.Log("During adding list to interface, invalid information was sent.")
          end
          
          return boolAdded
     end

     def AddListItem(strDesign, strItemDesign)

          boolAdded = false         # Indicator That Item was Added
#          hList = @hhComponents[strDesign]   
                                     # Selected List Information
          
          if strDesign && 
             strDesign != "" && 
             strItemDesign && 
             strItemDesign != ""
        
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 3
                    
                    if @hhComponents.has_key?(strItemDesign) == true && strDesign != strItemDesign
                
                         hList = @hhComponents[strDesign]
                         
                         if hList.has_key?(strItemDesign) == true
                              
                              hList.delete(strItemDesign)
                         end
               
                         if hList['ITEMS'].has_key?(strItemDesign) == true
                              
                              hList['ITEMS'].delete(strItemDesign)
                         end
                         
                         hList['ITEMS'][strItemDesign] = @hhComponents[strItemDesign]
                         
                         case hList['TYPE']
                              when 0

                                   @hhComponents[strItemDesign]['XOFFSET'] = hList['XOFFSET'] + (hList['ITEMWIDTH'] * (hList['ITEMS'].length - 1))
                                   @hhComponents[strItemDesign]['YOFFSET'] = hList['YOFFSET']
                              when 1

                                   @hhComponents[strItemDesign]['XOFFSET'] = hList['XOFFSET'] 
                                   @hhComponents[strItemDesign]['YOFFSET'] = hList['YOFFSET'] + (hList['ITEMHEIGHT'] * (hList['ITEMS'].length - 1))
                              else

                                   @hhComponents[strItemDesign]['XOFFSET'] = hList['XOFFSET'] + (hList['ITEMWIDTH'] * (hList['ITEMS'].length - 1))
                                   @hhComponents[strItemDesign]['YOFFSET'] = hList['YOFFSET'] + (hList['ITEMHEIGHT'] * (hList['ITEMS'].length - 1))
                         end

                         ReDraw()
                         
                         boolAdded = true
                    else
                    
                         BGMRPGM_Core.Log("During adding interface list item, item, designation, '" + strItemDesign + "', was not found or the same designation as the main list.")
                    end
               else
     
                    BGMRPGM_Core.Log("During adding interface list item, list, designation, '" + strDesign + "', was not found.")
               end
          else
             
               BGMRPGM_Core.Log("During adding list item to interface, invalid information was sent.")
          end
          
          return boolAdded
     end
     
     def AddButton(strDesign, nXOffset, nYOffset, nWidth, nHeight, strText = nil, boolDispose = true)
       
         gdInput = nil             # Newly Created Input
     
          if strDesign && 
             strDesign != ""
               
               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset) == true
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign, boolDispose)
                    end
                    
                    gdInput = BGMRPGM_Input.new(@nXPos + nXOffset, @nYPos + nYOffset, nWidth, nHeight)
                    gdInput.SetGetAllText(true)
                    
                    if strText

                         gdInput.SetDefaultCharLimit(strText.length)
                         gdInput.SetDefaultText(strText)
                    end
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 4,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset,
                                                'INPUT' => gdInput,
                                                'CLICKABLE' => true}

                    ReDraw()
               else
              
                    BGMRPGM_Core.Log("During adding interface button, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end
          else
              
                BGMRPGM_Core.Log("During adding interface button, invalid information was sent.")
          end
         
         return gdInput
     end

     def AddImage(strDesign, nXOffset, nYOffset, bmImage, nZPos = 100, boolDispose = true)
       
#         spImage = Sprite.new()
                                    # Sprite for Image
         boolAdded = false          # Indicator That Image was Added
     
         if strDesign && 
            strDesign != "" && 
            bmImage
               
               if IsInBounds?(@nXPos + nXOffset, @nYPos + nYOffset) == true
                    
                    if @hhComponents.has_key?(strDesign) == true 
     
                         RemoveComp(strDesign, boolDispose)
                    end
                    
                    spImage = Sprite.new()
                    spImage.bitmap = bmImage
                                                
                    spImage.x = @nXPos + nXOffset
                    spImage.y = @nYPos + nYOffset
                    spImage.z = nZPos
                    spImage.update
                    
                    @hhComponents[strDesign] = {'COMPONENT' => 5,
                                                'XOFFSET' => nXOffset,
                                                'YOFFSET' => nYOffset,
                                                'IMAGE' => spImage}

                    boolAdded = true

                    ReDraw()
               else
              
                    BGMRPGM_Core.Log("During adding interface image, designation, '" + strDesign + "', was out of the bounds of the interface.")
               end
         else
              
                BGMRPGM_Core.Log("During adding interface image, invalid information was sent.")
         end
         
         return boolAdded
     end

     def SetText(strDesign, strText) 
          
          boolSet = false           # Indicator That Text was Set
     
          if strDesign && 
             strDesign != "" && 
             strText
     
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 0
                    
                    @hhComponents[strDesign]['TEXT'] = strText;
                                          
                    boolSet = true

                    ReDraw()
               else
                 
                    BGMRPGM_Core.Log("During setting interface text, designation, '" + strDesign + "', was not found.")
               end
          else
             
               BGMRPGM_Core.Log("During setting interface text, invalid information was sent.")
          end
          
          return boolSet
     end
     
     def SetBarValue(strDesign, nValue, boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set

          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['VALUE'] = nValue                                     
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During setting interface bar value, designation, '" + strDesign + "', was not found.")
               end
               
               if boolForceUpdate == true
                    
                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During setting interface bar value, invalid information was sent.")
          end
          
          return boolSet
     end

     def SetBarLimit(strDesign, nLimit, boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set

          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['LIMIT'] = nLimit                                     
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During setting interface bar limit, designation, '" + strDesign + "', was not found.")
               end
     
               if boolForceUpdate == true

                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During setting interface bar limit, invalid information was sent.")
          end
          
          return boolSet
     end

     def SetBarColor(strDesign, cColorBar, cColorBack = gauge_back_color(), boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set

          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['COLORFOREGROUND'] = cColorBar
                    @hhComponents[strDesign]['COLORBACKGROUND'] = cColorBack                                   
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During setting interface bar color, designation, '" + strDesign + "', was not found.")
               end
     
               if boolForceUpdate == true

                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During setting interface bar color, invalid information was sent.")
          end
          
          return boolSet
     end

     def SetBarVisibility(strDesign, boolVisible, boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set

          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['SHOW'] = boolVisible                                     
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During setting interface bar visibility, designation, '" + strDesign + "', was not found.")
               end
          
               if boolForceUpdate == true

                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During setting interface bar visibility, invalid information was sent.")
          end
          
          return boolSet
     end

     def SetBarTimeLimit(strDesign, fTimeLimitInMillis, boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set

          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['TIME'] = fTimeLimitInMillis                                     
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During setting interface bar time limit, designation, '" + strDesign + "', was not found.")
               end
          
               if boolForceUpdate == true

                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During setting interface bar time limit, invalid information was sent.")
          end
          
          return boolSet
     end

     def SetInputSendFunc(strDesign, objDestination, strFuncName)

        boolSet = false            # Indicator That Function Call was Set

        if strDesign && 
           strDesign != "" &&
           objDestination &&
           strFuncName &&
           strFuncName != ""
           
             if @hhComponents.has_key?(strDesign) == true && 
                @hhComponents[strDesign]['COMPONENT'] == 2
                
                  boolSet = @hhComponents[strDesign]['INPUT'].SetFuncCall(objDestination, strFuncName)
             else
             
                  BGMRPGM_Core.Log("During setting interface input text send function, designation, '" + strDesign + "', was not found.")
             end
        else
          
             BGMRPGM_Core.Log("During setting interface input text send function, invalid information was sent.")
        end
                 
        return boolSet
     end
     
     def SetButtonSendFunc(strDesign, objDestination, strFuncName)
     
        boolSet = false            # Indicator That Function Call was Set
  
        if strDesign && 
           strDesign != "" &&
           objDestination &&
           strFuncName &&
           strFuncName != ""
           
             if @hhComponents.has_key?(strDesign) == true && 
                @hhComponents[strDesign]['COMPONENT'] == 4
                
                  boolSet = @hhComponents[strDesign]['INPUT'].SetFuncCall(objDestination, strFuncName)
             else
             
                  BGMRPGM_Core.Log("During setting interface button send function, designation, '" + strDesign + "', was not found.")
             end
        else
       
             BGMRPGM_Core.Log("During setting interface button send function, invalid information was sent.")
        end
        
        return boolSet
     end

     def SetButtonMouseInSendFunc(strDesign, objDestination, strFuncName)
      
         boolSet = false            # Indicator That Function Call was Set
         
         if strDesign && 
            strDesign != "" &&
            objDestination &&
            strFuncName &&
            strFuncName != ""
            
              if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                 
                   boolSet = @hhComponents[strDesign]['INPUT'].SetMouseInFuncCall(objDestination, strFuncName)
              else
              
                   BGMRPGM_Core.Log("During setting interface button mouse in send function, designation, '" + strDesign + "', was not found.")
              end
         else
          
              BGMRPGM_Core.Log("During setting interface button mouse in send function, invalid information was sent.")
         end
        
         return boolSet
     end

     def SetButtonMouseOutSendFunc(strDesign, objDestination, strFuncName)
       
          boolSet = false            # Indicator That Function Call was Set
          
          if strDesign && 
             strDesign != "" &&
             objDestination &&
             strFuncName &&
             strFuncName != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                  
                    boolSet = @hhComponents[strDesign]['INPUT'].SetMouseOutFuncCall(objDestination, strFuncName)
               else
               
                    BGMRPGM_Core.Log("During setting interface button mouse out send function, designation, '" + strDesign + "', was not found.")
               end
          else
           
               BGMRPGM_Core.Log("During setting interface button mouse out send function, invalid information was sent.")
          end
         
          return boolSet
     end

     def SetButtonMouseClickSendFunc(strDesign, objDestination, strFuncName, nClickType = 0)
        
           boolSet = false            # Indicator That Function Call was Set
           
           if strDesign && 
              strDesign != "" &&
              objDestination &&
              strFuncName &&
              strFuncName != ""
              
                if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                   
                     boolSet = @hhComponents[strDesign]['INPUT'].SetMouseClickFuncCall(objDestination, strFuncName, nClickType)
                else
                
                     BGMRPGM_Core.Log("During setting interface button mouse click send function, designation, '" + strDesign + "', was not found.")
                end
           else
           
                BGMRPGM_Core.Log("During setting interface button mouse click send function, invalid information was sent.")
           end
          
           return boolSet
     end
     
     def SetInputButtonFrame(strDesign, bmImage)
       
          boolSet = false            # Indicator That Input or Button Window Frame was Set
          
          if strDesign && 
             strDesign != "" &&
             bmImage
             
               if @hhComponents.has_key?(strDesign) == true && 
                  (@hhComponents[strDesign]['COMPONENT'] == 2 || 
                   @hhComponents[strDesign]['COMPONENT'] == 4)
                  
                    boolSet = @hhComponents[strDesign]['INPUT'].SetWindowFrame(bmImage)
               else
               
                    BGMRPGM_Core.Log("During setting interface input or button's frame image, designation, '" + strDesign + "', was not found.")
               end
          else
          
               BGMRPGM_Core.Log("During setting interface input or button's frame image, invalid information was sent.")
          end
         
          return boolSet
     end 

     def SetInputButtonBackColor(strDesign, nColor = nil)
       
          boolSet = false            # Indicator That Input or Button Window Background Color was Set
          
          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && 
                  (@hhComponents[strDesign]['COMPONENT'] == 2 || 
                   @hhComponents[strDesign]['COMPONENT'] == 4)
                  
                    boolSet = @hhComponents[strDesign]['INPUT'].SetWindowBackColor(nColor)
               else
               
                    BGMRPGM_Core.Log("During setting interface input or button's background color, designation, '" + strDesign + "', was not found.")
               end
          else
          
               BGMRPGM_Core.Log("During setting interface input or button's background color, invalid information was sent.")
          end
         
          return boolSet
     end 
     
     def SetImage(strDesign, bmImage, boolDispose = true) 
          
          boolSet = false           # Indicator That Image was Set
     
          if strDesign && 
             strDesign != "" && 
             bmImage
     
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 5
                    
                    if boolDispose == true
                    
                         @hhComponents[strDesign]['IMAGE'].bitmap.dispose
                    end

                    @hhComponents[strDesign]['IMAGE'].bitmap = bmImage
                                     
                    boolSet = true
                    ReDraw()
               else
                 
                    BGMRPGM_Core.Log("During setting interface image, designation, '" + strDesign + "', was not found.")
               end
          else
             
               BGMRPGM_Core.Log("During setting interface image, invalid information was sent.")
          end
          
          return boolSet
     end
     
     def ResetBarTime(strDesign, boolForceUpdate = false) 
          
          boolSet = false           # Indicator That Value was Set
          
          if strDesign && 
             strDesign != ""
             
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 1
                    
                    @hhComponents[strDesign]['START'] = Time.now                                     
                    boolSet = true
               else
               
                    BGMRPGM_Core.Log("During resetting interface bar time, designation, '" + strDesign + "', was not found.")
               end
          
               if boolForceUpdate == true

                    ReDraw()
               end
          else
          
               BGMRPGM_Core.Log("During resetting interface bar time, invalid information was sent.")
          end
          
          return boolSet
     end
     
     def AddInputText(strDesign, strAddText)
       
          boolSet = false           # Indicator That Value was Set
          
          if strDesign && strAddText
               
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
                   
                    @hhComponents[strDesign]['INPUT'].AddText(strAddText)                                    
                    boolSet = true
                    ReDraw()
               else
               
                    BGMRPGM_Core.Log("During adding text to interface input, designation, '" + strDesign + "', was not found.")
               end
          else
          
               BGMRPGM_Core.Log("During adding text to interface input, invalid information was sent.")
          end
          
          return boolSet
     end

     def GetInput(strDesign) 
          
          gdInput = nil             # Selected Input

          if strDesign && 
             strDesign != ""
     
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
                    
                    gdInput = @hhComponents[strDesign]['INPUT']
               end
          else
              
                BGMRPGM_Core.Log("During getting input from interface, invalid information was sent.")
          end
          
          return gdInput
     end

     def GetButton(strDesign) 
           
          gdInput = nil             # Selected Input

          if strDesign && 
             strDesign != ""
               
               if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                     
                     gdInput = @hhComponents[strDesign]['INPUT']
               end
          else
              
                BGMRPGM_Core.Log("During getting button from interface, invalid information was sent.")
          end
           
          return gdInput
     end

     def GetListInputButton(strDesign, strItemDesign)
            
          giItem = nil              # Selected List Item
#          hItem = @hhComponents[strDesign]['ITEMS'][strItemDesign]
                                     # Information on Selected List Item

          if strDesign && 
             strDesign != "" && 
             strItemDesign && 
             strItemDesign != ""
     
               if @hhComponents.has_key?(strDesign) == true && 
                  @hhComponents[strDesign]['COMPONENT'] == 3 && 
                  @hhComponents[strDesign]['ITEMS'].has_key?(strItemDesign) == true &&
                       
                   hItem = @hhComponents[strDesign]['ITEMS'][strItemDesign]
                        
                   if hItem['COMPONENT'] == 2 || hItem['COMPONENT'] == 4
                        
                       giItem = hItem['INPUT']
                   end
               end
          else
             
               BGMRPGM_Core.Log("During getting list item from interface, invalid information was sent.")
          end
            
          return giItem
     end
     
     def CheckCompExists(strDesign, nCompType = -1)
         
          boolExists = false        # Indicator That Component Exists
          
          @hhComponents.clone().each { |strCompDesign, hComponent|
             
               if strDesign == strCompDesign && (nCompType == -1 || nCompType == hComponent['COMPONENT']) 
               
                    boolExists = true
                    break
               end
          }
          
          return boolExists
     end
     
     def CheckListItemExists(strDesign, strItemDesign, nCompType = -1)
         
          boolExists = false        # Indicator That List Item Exists
          
          @hhComponents.clone().each { |strCompDesign, hComponent|
             
               if strDesign == strCompDesign && hComponent['COMPONENT'] == 3 
               
                    hComponent['ITEMS'].each { |strItemSelect, hItem|
                    
                         if strItemDesign == strItemSelect && (nCompType == -1 || nCompType == hItem['COMPONENT']) 
                         
                              boolExists = true
                              break
                         end
                    }
               end
          }
          
          return boolExists
     end
     
     def ToggleClickable(strDesign)

         boolSet = false           # Indicator That Value was Set
         
         if @hhComponents.has_key?(strDesign) == true && 
            (@hhComponents[strDesign]['COMPONENT'] == 2 || 
             @hhComponents[strDesign]['COMPONENT'] == 4)
           
               if @hhComponents[strDesign]['CLICKABLE'] == false
                 
                    @hhComponents[strDesign]['CLICKABLE'] = true
               else
      
                    @hhComponents[strDesign]['CLICKABLE'] = false
               end
    
               boolSet = true
          else
          
               BGMRPGM_Core.Log("During toggling interface button clickable, designation, '" + strDesign + "', was not found.")
          end
        
          return boolSet
     end
     
     def DeleteInputText(strDesign, boolByWord = false)
      
        boolSet = false           # Indicator That Value was Set
          
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
                 
                 @hhComponents[strDesign]['INPUT'].DeleteText(boolByWord)                                    
                 boolSet = true
             else
           
                 BGMRPGM_Core.Log("During deleting text from interface input, designation, '" + strDesign + "', was not found.")
             end
        else
          
            BGMRPGM_Core.Log("During deleting text from interface input, invalid information was sent.")
        end
        
        return boolSet
     end
    
     def ClearInputText(strDesign)
     
       boolSet = false           # Indicator That Value was Set
  
       if strDesign
            
            if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
                
                @hhComponents[strDesign]['INPUT'].ClearText()                                 
                boolSet = true
            else
           
                BGMRPGM_Core.Log("During clearing text from interface input, designation, '" + strDesign + "', was not found.")
            end
       else
       
           BGMRPGM_Core.Log("During clearing text from interface input, invalid information was sent.")
       end
       
       return boolSet
     end

     def RemoveInputSendFuncs(strDesign)
   
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && 
                @hhComponents[strDesign]['COMPONENT'] == 2
              
                  @hhComponents[strDesign]['INPUT'].ClearFuncs()
             else
             
                  BGMRPGM_Core.Log("During removing interface input text send functions, designation, '" + strDesign + "', was not found.")
             end
        else
     
             BGMRPGM_Core.Log("During removing interface input text send functions, invalid information was sent.")
        end
     end

     def RemoveButtonSendFuncs(strDesign)
  
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && 
                @hhComponents[strDesign]['COMPONENT'] == 4
              
                  @hhComponents[strDesign]['INPUT'].ClearFuncs()
             else
             
                  BGMRPGM_Core.Log("During removing interface input button send functions, designation, '" + strDesign + "', was not found.")
             end
        else
          
             BGMRPGM_Core.Log("During removing interface input button send functions, invalid information was sent.")
        end
     end

     def ReadInputText(strDesign, boolClear = true)
    
       strText = ""                 # Text from Input
  
       if strDesign
            
            if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
               
                 strText = @hhComponents[strDesign]['INPUT'].GetText(boolClear)
            else
             
                 BGMRPGM_Core.Log("During reading interface input text, designation, '" + strDesign + "', was not found.")
            end
       else
     
            BGMRPGM_Core.Log("During reading interface input text, invalid information was sent.")
       end
      
       return strText
     end

     def SendInput(strDesign)
  
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 2
                
                  @hhComponents[strDesign]['INPUT'].CallFuncs()
             else
             
                  BGMRPGM_Core.Log("During calling interface input functions, designation, '" + strDesign + "', was not found.")
             end
        else
     
             BGMRPGM_Core.Log("During calling interface input functions, invalid information was sent.")
        end
     end

     def SendMouseIn(strDesign)
  
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                
                  @hhComponents[strDesign]['INPUT'].CallMouseInFuncs()
             else
             
                  BGMRPGM_Core.Log("During calling interface button function during mouse in event, designation, '" + strDesign + "', was not found.")
             end
        else
     
             BGMRPGM_Core.Log("During calling interface button function during mouse in event, invalid information was sent.")
        end
     end

     def SendMouseOut(strDesign)
  
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                
                  @hhComponents[strDesign]['INPUT'].CallMouseOutFuncs()
             else
             
                  BGMRPGM_Core.Log("During calling interface button function during mouse out event, designation, '" + strDesign + "', was not found.")
             end
        else
          
             BGMRPGM_Core.Log("During calling interface button function during mouse out event, invalid information was sent.")
        end
     end

     def SendMouseClick(strDesign, nClickType = 0)
  
        if strDesign
             
             if @hhComponents.has_key?(strDesign) == true && @hhComponents[strDesign]['COMPONENT'] == 4
                
                  @hhComponents[strDesign]['INPUT'].CallMouseClickFuncs(nClickType)
             else
             
                  BGMRPGM_Core.Log("During calling interface button function during mouse click event, designation, '" + strDesign + "', was not found.")
             end
        else
          
             BGMRPGM_Core.Log("During calling interface button function during mouse click event, invalid information was sent.")
        end
     end

     def FindButtonsByPos(nXPos, nYPos)
     
        aButtonList = []            # List of Buttons That are in the Bounds
           
        @hhComponents.clone().each { |strDesign, hComponent|
           
             if hComponent['COMPONENT'] == 4 && hComponent['INPUT'].IsInBounds?(nXPos, nYPos) == true
             
                  aButtonList.push(strDesign) 
             end
        }
        
        return aButtonList
     end

     def FindInputsByPos(nXPos, nYPos)
     
        aInputList = []             # List of Inputs That are in the Bounds
           
        @hhComponents.clone().each { |strDesign, hComponent|
           
             if hComponent['COMPONENT'] == 2 && hComponent['INPUT'].IsInBounds?(nXPos, nYPos) == true
             
                  aInputList.push(strDesign) 
             end
        }
        
        return aInputList
     end
     
     def FindNextInputDesign(strSelectDesign)
        
          strNextDesign = nil       # Next Found Design After Sent
          boolSelectFound = false   # Indicator That Input or Button of the Select Design

          if strSelectDesign &&
             strSelectDesign != ""
             
               @hhComponents.clone().each {  |strCompDesign, hComponentSelect| 
                         
                    if hComponentSelect['COMPONENT'] == 2 &&
                       hComponentSelect['INPUT'].IsVisible() == true
                        
                        if strSelectDesign == strCompDesign
                             
                             boolSelectFound = true
                                  
                             if !strNextDesign
                                
                                  strNextDesign = strCompDesign
                             end
                             
                        elsif !strNextDesign
                           
                             strNextDesign = strCompDesign
                                  
                        elsif boolSelectFound == true
                                
                             strNextDesign = strCompDesign
                             break
                        end
                    end
               }
          end

          return strNextDesign
     end

     def FindListInputButtonByPos(nXPos, nYPos)
     
        hListItemsList = {}         # List of List Items That are in the Bounds
             
        @hhComponents.clone().each { |strDesign, hComponent|
           
             if hComponent['COMPONENT'] == 3 
                  
                  hComponent['ITEMS'].each { |strItemDesign, hItem|
                       
                       if (hItem['COMPONENT'] == 2 || hItem['COMPONENT'] == 4) &&
                          hItem['INPUT'].IsInBounds?(nXPos, nYPos) == true
             
                            if hListItemsList.has_key?(strDesign) == false
                                 
                                 hListItemsList[strDesign] = [strItemDesign]
                            else
                       
                                 hListItemsList[strDesign].push(strItemDesign) 
                            end
                       end
                  }
             end
        }
        
        return hListItemsList
     end
     
     def IsClickable(strDesign)

          boolClickable = false     # Indicator That Button is Clickable
  
          if strDesign
               
               if @hhComponents.has_key?(strDesign) == true && 
                  (@hhComponents[strDesign]['COMPONENT'] == 2 || 
                   @hhComponents[strDesign]['COMPONENT'] == 4)
                 
                   boolClickable = @hhComponents[strDesign]['CLICKABLE']
               else
              
                   BGMRPGM_Core.Log("During finding if interface input or button is clickable, designation, '" + strDesign + "', was not found.")
               end
          else
          
               BGMRPGM_Core.Log("During finding if interface input or button is clickable, invalid information was sent.")
          end
          
          return boolClickable
     end

     def RemoveComp(strDesign, boolDispose = true) 
          
#         spImage = @hhComponents[strDesign]['IMAGE']     
                                    # Sprite Image
          boolRemove = false        # Indicator That Text was Removed
  
          if strDesign       
               
               if @hhComponents.has_key?(strDesign) == true
                    
                    case @hhComponents[strDesign]['COMPONENT']
                      
                         when 2
                   
                              if boolDispose == true

                                   @hhComponents[strDesign]['INPUT'].dispose
                              end
                         when 3 
                           
                              @hhComponents[strDesign]['ITEMS'].keys.clone().each { |strItemDesign| 

                                   RemoveListItem(strDesign, strItemDesign)
                              }
                         when 4
                         
                              if boolDispose == true

                                   @hhComponents[strDesign]['INPUT'].dispose
                              end
                         when 5

                              spImage = @hhComponents[strDesign]['IMAGE']
                                   
                              if spImage.bitmap && boolDispose == true

                                   spImage.bitmap.dispose
                              end
                              
                              if boolDispose == true

                                   spImage.dispose
                              end
                    end
                    
                    @hhComponents.delete(strDesign)

                    @hhComponents.each { |strDesignSelect, hItem| 
                    
                         if hItem['COMPONENT'] == 3
                              
                              if hItem['ITEMS'].has_key?(strDesign) == true
                              
                                   hItem['ITEMS'].delete(strDesign)
                              end
                         end
                    }
                    
                    boolRemove = true
               else
               
                    BGMRPGM_Core.Log("During removing interface component, designation, '" + strDesign + "', was not found.")
               end
          else
          
               BGMRPGM_Core.Log("During removing interface component, invalid information was sent.")
          end
          
          return boolRemove
     end
     
     def RemoveListItem(strDesign, strItemDesign)
        
          boolRemove = false        # Indicator That Value was Removed
 
          if strDesign && 
             strDesign != "" && 
             strItemDesign && 
             strItemDesign != ""
     
               if @hhComponents.has_key?(strDesign) == true && 
                  @hhComponents[strDesign]['ITEMS'].has_key?(strItemDesign) == true && 
                  @hhComponents[strDesign]['COMPONENT'] == 3

                  @hhComponents[strDesign]['ITEMS'].delete(strItemDesign)
                  boolRemove = true
               else
              
                   BGMRPGM_Core.Log("During removing list item from interface list, designation, '" + strDesign + "', item, designation, '" + strItemDesign + "', was not found.")
               end
          else
             
               BGMRPGM_Core.Log("During removing list item from interface, invalid information was sent.")
          end
          
          return boolRemove
     end

     def Clear(boolDispose = true)

          @hhComponents.clone().each { |strDesignSelect, hComponentSelect| 
          
               RemoveComp(strDesignSelect, boolDispose) 
          }
     end 
     
     def Draw(nSetXPos = @nXPos, nSetYPos = @nYPos, boolForceUpdate = false)
         
#          strText = ""             # Holder for Text 
#          nXTotalPos = @nXPos + hComponentSelect['XOFFSET']
                                    # X-Axis Position
#          nYTotalPos = @nYPos + hComponentSelect['YOFFSET']
                                    # Y-Axis Position
#          spImage = hComponentSelect['IMAGE']
                                    # Sprite Image          
          nOpacity = 255           # Opacity Value for Components   
          boolMoved = false        # Indicator That Movement Occurred

          if disposed?() == false 

               @mtxLock.lock()

               if @mxFollower
                    
                    @nXPos = @mxFollower.screen_x + @nXFollowOffset
                    @nYPos = @mxFollower.screen_y + @nYFollowOffset
               else

                    @nXPos = nSetXPos
                    @nYPos = nSetYPos
               end

               if self.x != @nXPos || self.y != @nYPos

                    self.x = @nXPos
                    self.y = @nYPos

                    boolMoved = true
               end
               
               if @boolVisible == true
                    
                    if @nMode == 0

                         self.opacity = 255
                    end
          
                    if boolMoved == true || boolForceUpdate = true

                         contents.clear()
               
                         @hhComponents.each { |strDesignSelect, hComponentSelect| 
                         
                              case hComponentSelect['COMPONENT']
                                   
                                   when 0
               
                                        strText = hComponentSelect['TEXT']
                                             
                                        draw_text(hComponentSelect['XOFFSET'], 
                                                  hComponentSelect['YOFFSET'], 
                                                  text_size(strText).width, 
                                                  text_size(strText).height, 
                                                  strText)
                                                  
                                   when 1
                                        
                                        case hComponentSelect['TYPE'] 
                                             
                                             when 1 
                                             
                                                  if hComponentSelect['VALUE'] > 0
               
                                                       hComponentSelect['SHOW'] = true
                                                  else
                                             
                                                       hComponentSelect['SHOW'] = false
                                                  end
                                                  
                                             when 2
                                             
                                                  if hComponentSelect['TIME'] > 0 && 
                                                     hComponentSelect['VALUE'] > 0 &&
                                                     (Time.now - hComponentSelect['START']) * 1000 < hComponentSelect['TIME']

                                                       hComponentSelect['VALUE'] = ((hComponentSelect['VALUE'] * 
                                                                                     (((hComponentSelect['TIME'] - ((Time.now - hComponentSelect['START']) * 1000)) * 100) / 
                                                                                     hComponentSelect['TIME'])) / 100).to_i
                                                       hComponentSelect['SHOW'] = true

                                                  else
                                                       
                                                       hComponentSelect['SHOW'] = false
                                                  end
                                        end
                                        
                                        if hComponentSelect['SHOW'] == true
               
                                             draw_gauge((hComponentSelect['VALUE'] * 100 / hComponentSelect['LIMIT']).to_i, 
                                                        hComponentSelect['XOFFSET'], 
                                                        hComponentSelect['YOFFSET'],
                                                        hComponentSelect['WIDTH'],
                                                        hComponentSelect['HEIGHT'],
                                                        hComponentSelect['COLORFOREGROUND'],
                                                        hComponentSelect['COLORBACKGROUND'])
                                        end
                                        
                                   when 2 
                                        
                                        hComponentSelect['INPUT'].SetPos(@nXPos + hComponentSelect['XOFFSET'], @nYPos + hComponentSelect['YOFFSET'])       

                                   when 4 
                              
                                        hComponentSelect['INPUT'].SetPos(@nXPos + hComponentSelect['XOFFSET'], @nYPos + hComponentSelect['YOFFSET'])
                                                       
                                   when 5 
                                        
                                        spImage = hComponentSelect['IMAGE']
                                             
                                        spImage.x = @nXPos + hComponentSelect['XOFFSET']
                                        spImage.y = @nYPos + hComponentSelect['YOFFSET']
                                        spImage.update
                                             
                              end
                         }
                    end
               else

                    if @nMode == 0

                         self.opacity = 0
                    end

                    nOpacity = 0
                    contents.clear()
               end
               
               if @boolUpdated == true
                    
                    @hhComponents.each { |strDesignSelect, hComponentSelect| 
                    
                         case hComponentSelect['COMPONENT']
                              
                              when 2 
                                   
                                   hComponentSelect['INPUT'].Show(@boolVisible)      
          
                              when 4 
                         
                                   hComponentSelect['INPUT'].Show(@boolVisible)
                                                  
                              when 5 
                                   
                                   hComponentSelect['IMAGE'].opacity = nOpacity
                                   hComponentSelect['IMAGE'].update
                                        
                         end
                    }
                  
                    @boolUpdated = false  
               end

               @mtxLock.unlock()
          end
     end

     def ReDraw()

          Draw(@nXPos, @nYPos, true)
     end

     def ReDrawBars() 

          @hhComponents.each { |strDesignSelect, hComponentSelect| 

               if hComponentSelect['COMPONENT'] == 1 && 
                  hComponentSelect['TYPE'] == 2 && 
                  hComponentSelect['SHOW'] == true

                    Draw(@nXPos, @nYPos, true)
               end
          }
     end
     
     def Follow
        
          if @mxFollower
               
               ReDraw()
          end  
     end
     
     def SetFollower(mxSetFollower, nSetXFollowOffset = @nXFollowOffset, nSetYFollowOffset = @nYFollowOffset)

          @mxFollower = mxSetFollower   
          @nXFollowOffset = nSetXFollowOffset
          @nYFollowOffset = nSetYFollowOffset  
     end
     
     def RemoveFollower

          @mxFollower = nil      
          @nXFollowOffset = 0 
          @nYFollowOffset = 0 
     end
     
     def SetPos(nSetXPos, nSetYPos)

          boolSet = false           # Indicator That Position was Changed
          
          if nSetXPos != @nXPos || nSetYPos != @nYPos
               
               Draw(nSetXPos, nSetYPos)
               boolSet = true
          end
          
          return boolSet
     end
     
     def SetMode(nSetMode)
          
          boolThreadMustEnd = false # Indicator That Thread Needs to End
          
          @nMode = nSetMode
          
          case nSetMode
               when 0
                    
                    self.opacity = 255
                    boolThreadMustEnd = true
                    
               when 1
               
                    if !@thdBlink
                         
                         @thdBlink = Thread.new(self) { |giOwner| 
                              
                              tmBlinkStart = tmCurrent = tmLastBlink = Time.now 
                                                     # Start, Current Time, and Last Time Blink Interval
                              boolVisible = giOwner.opacity >= 255
                                                     # Indicator to Visible Part of Blink
                                                     
                              while tmCurrent - tmBlinkStart < giOwner.GetBlinkDurationSecs()
                                
                                   if  tmCurrent - tmLastBlink >= giOwner.GetBlinkIntervalSecs() 
                                  
                                        if boolVisible == true
                                             
                                             giOwner.opacity = (translucent_alpha / 2).to_i

                                        else
                                             
                                             giOwner.opacity = 255
                                        end
                                           
                                        boolVisible = !boolVisible
                                        tmLastBlink = Time.now
                                   end
                                   
                                   sleep(0.1)
                                   
                                   tmCurrent = Time.now
                              end
                              
                              giOwner.opacity = 255
                         }
                    end
               when 2       
               
                    self.opacity = (translucent_alpha / 2).to_i
                    boolThreadMustEnd = true
               else
                 
                    BGMRPGM_Core.Log("During setting interface mode, invalid value of " + nSetMode.to_s + " was sent.")
          end

          if @thdBlink && boolThreadMustEnd == true
               
               @thdBlink.join
               @thdBlink = nil
          end
     end
     
     def SetBlinkDurationSecs(nSetBlinkDurationSecs = 5)

          if nSetBlinkDurationSecs.is_a?(Fixnum) == true && nSetBlinkDurationSecs >= 0
               
               @nBlinkDurationSecs = nSetBlinkDurationSecs
          end
     end

     def SetBlinkIntervalSecs(fSetBlinkIntervalSecs = 0.25)
     
          if fSetBlinkIntervalSecs.is_a?(Fixnum) == true &&
             fSetBlinkIntervalSecs.is_a?(Float) == true &&  
             fSetBlinkIntervalSecs >= 0
               
               @fBlinkIntervalSecs = fSetBlinkIntervalSecs
          end
     end
     
     def Show(boolSetVisible = true)
          
          @boolVisible = boolSetVisible  
          @boolUpdated = true
     end
     
     def GetMode
          
          return @nMode
     end
     
     def GetBlinkDurationSecs
     
          return @nBlinkDurationSecs
     end
     
     def GetBlinkIntervalSecs
     
          return @fBlinkIntervalSecs
     end
     
     def DequeueEventFuncs
          
          ahMouseEvents = []        # List of Mouse Events to Execute
          
          @hhComponents.clone().each { |strDesignSelect, hComponentSelect|
                         
               if hComponentSelect.has_key?("INPUT") == true
          
                    ahMouseEvents += hComponentSelect["INPUT"].DequeueEventFuncs()
               end
          }
          
          return ahMouseEvents
     end
          
     def dispose
          
          aRemoveList = []          # List of Components to Remove
               
          @hhComponents.each { |strDesignSelect, hComponentSelect|
                         
               if hComponentSelect['COMPONENT'] > 1
          
                    aRemoveList.push(strDesignSelect)
               end
          }
          
          aRemoveList.each { |strDesignSelect|
                    
               RemoveComp(strDesignSelect)
          }
          
          if @thdBlink
               
               @thdBlink.join
               @thdBlink = nil
          end
          
          super
     end
     
     private 
     
          def draw_gauge(nStartPercent, nBarXPos, nBarYPos, nBarWidth, nBarHeight, cColorBar, cColorBack)

            contents.fill_rect(nBarXPos, nBarYPos, nBarWidth, nBarHeight, cColorBack)
            contents.fill_rect(nBarXPos + 5, nBarYPos + 5, (nBarWidth - 10) * nStartPercent / 100, nBarHeight - 10, cColorBar)
          end
end

module Input
     
     class << self
          
          alias :doTrigger :trigger?# Trigger Method Alias
          alias :doRepeat :repeat?  # Repeat Method Alias
          alias :doPress :press?    # Press Method Alias 
     end 

     def self.trigger?(mxKeyValue)
          
          boolResult = false        # Indicator That Key was Triggered
          
          if BGMRPGM_Core.HasKeyMapping(mxKeyValue) == false
               
               boolResult = doTrigger(mxKeyValue)
          end
          
          return boolResult
     end
     
     def self.repeat?(mxKeyValue)
          
          boolResult = false        # Indicator That Key was Triggered
          
          if BGMRPGM_Core.HasKeyMapping(mxKeyValue) == false
               
               boolResult = doRepeat(mxKeyValue)
          end
          
          return boolResult
     end
     
     def self.press?(mxKeyValue)
          
          boolResult = false        # Indicator That Key was Triggered
          
          if BGMRPGM_Core.HasKeyMapping(mxKeyValue) == false
               
               boolResult = doPress(mxKeyValue)
          end
          
          return boolResult
     end
end

# Added Cleanup to Main Shutdown Process
class Scene_End
     
     alias doShutdown command_shutdown 
                                    # Alias for Game Shutdown Function
     
     def command_shutdown

          # Before Shutdown, Cleanup
          BGMRPGM_Core.Close()
          
          doShutdown

     end
end

# Added Processing Direct Messages to Main Update Loop
class Scene_Base
     
     alias doUpdate update          # Alias for Game Update Function
     
     def update

          # Before Scene Processes, Processes All Incoming Direct Messages
          BGMRPGM_Core.Update
          
          doUpdate

     end
end