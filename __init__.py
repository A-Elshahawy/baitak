from .app import app

"""
    Now to build for a real device, you need your Windows machine's LAN IP. Find it by running this 
    in Windows PowerShell (not WSL):
                                                                                          
  ipconfig
  # Look for "IPv4 Address" under your WiFi adapter — e.g. 192.168.1.5                        
                                                                                          
  Then build the APK inside the devcontainer with that IP:                                        
                                                                                                  
  # For real device (replace with your actual Windows IP)                                         
  flutter build apk --debug --dart-define=BASE_URL=http://192.168.100.5:8000/api            

  # flutter build apk --debug      
                                                           
                                                                                                
  Also make sure the backend binds to all interfaces (not just localhost):                      
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000                                        
  The --host 0.0.0.0 makes it reachable from your phone on the same WiFi network.  
"""
"""
  netsh interface portproxy delete v4tov4 listenport=8000 listenaddress=0.0.0.0
  netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=172.20.65.184
"""
