VERSION='1.0.0'

main(){

 usage(){
  #!/bin/bash
cat << 'EOF'
          _____                    _____                _____                    _____                    _____                    _____                    _____                    _____          
         /\    \                  /\    \              /\    \                  /\    \                  /\    \                  /\    \                  /\    \                  /\    \         
        /::\    \                /::\    \            /::\    \                /::\____\                /::\    \                /::\    \                /::\    \                /::\____\        
       /::::\    \              /::::\    \           \:::\    \              /:::/    /                \:::\    \              /::::\    \              /::::\    \              /::::|   |        
      /::::::\    \            /::::::\    \           \:::\    \            /:::/    /                  \:::\    \            /::::::\    \            /::::::\    \            /:::::|   |        
     /:::/\:::\    \          /:::/\:::\    \           \:::\    \          /:::/    /                    \:::\    \          /:::/\:::\    \          /:::/\:::\    \          /::::::|   |        
    /:::/__\:::\    \        /:::/__\:::\    \           \:::\    \        /:::/____/                      \:::\    \        /:::/__\:::\    \        /:::/__\:::\    \        /:::/|::|   |        
   /::::\   \:::\    \      /::::\   \:::\    \          /::::\    \      /::::\    \                      /::::\    \       \:::\   \:::\    \      /::::\   \:::\    \      /:::/ |::|   |        
  /::::::\   \:::\    \    /::::::\   \:::\    \        /::::::\    \    /::::::\    \   _____    ____    /::::::\    \    ___\:::\   \:::\    \    /::::::\   \:::\    \    /:::/  |::|   | _____  
 /:::/\:::\   \:::\    \  /:::/\:::\   \:::\____\      /:::/\:::\    \  /:::/\:::\    \ /\    \  /\   \  /:::/\:::\    \  /\   \:::\   \:::\    \  /:::/\:::\   \:::\    \  /:::/   |::|   |/\    \ 
/:::/  \:::\   \:::\____\/:::/  \:::\   \:::|    |    /:::/  \:::\____\/:::/  \:::\    /::\____\/::\   \/:::/  \:::\____\/::\   \:::\   \:::\____\/:::/  \:::\   \:::\____\/:: /    |::|   /::\____\
\::/    \:::\  /:::/    /\::/   |::::\  /:::|____|   /:::/    \::/    /\::/    \:::\  /:::/    /\:::\  /:::/    \::/    /\:::\   \:::\   \::/    /\::/    \:::\  /:::/    /\::/    /|::|  /:::/    /
 \/____/ \:::\/:::/    /  \/____|:::::\/:::/    /   /:::/    / \/____/  \/____/ \:::\/:::/    /  \:::\/:::/    / \/____/  \:::\   \:::\   \/____/  \/____/ \:::\/:::/    /  \/____/ |::| /:::/    / 
          \::::::/    /         |:::::::::/    /   /:::/    /                    \::::::/    /    \::::::/    /            \:::\   \:::\    \               \::::::/    /           |::|/:::/    /  
           \::::/    /          |::|\::::/    /   /:::/    /                      \::::/    /      \::::/____/              \:::\   \:::\____\               \::::/    /            |::::::/    /   
           /:::/    /           |::| \::/____/    \::/    /                       /:::/    /        \:::\    \               \:::\  /:::/    /               /:::/    /             |:::::/    /    
          /:::/    /            |::|  ~|           \/____/                       /:::/    /          \:::\    \               \:::\/:::/    /               /:::/    /              |::::/    /     
         /:::/    /             |::|   |                                        /:::/    /            \:::\    \               \::::::/    /               /:::/    /               /:::/    /      
        /:::/    /              \::|   |                                       /:::/    /              \:::\____\               \::::/    /               /:::/    /               /:::/    /       
        \::/    /                \:|   |                                       \::/    /                \::/    /                \::/    /                \::/    /                \::/    /        
         \/____/                  \|___|                                        \/____/                  \/____/                  \/____/                  \/____/                  \/____/         
EOF

  echo "Deployment automation tool"
  echo ""
  echo "Options"
  echo "-h, --help 	Display help message"
  echo "-v, --version   Display current Arthisan version"
  echo "python		Start python automation"
  echo "nginx 		Start nginx automation"
  echo "ps	        Show running processes"
  echo "node		Start node automation"
 }

 version(){
  echo "Current Version ${VERSION}"
 }

 invalid_command(){
  echo "Command is not valid, please check the documentation"
 }

python_help() {
  echo ""
  echo "Usage: arthisan python [OPTIONS]"
  echo ""
  echo "Options:"
  echo "-h, --help              Display this help message"
  echo "-r, --requirement       Specify requirement file name, ex: requirementPython.txt"
  echo "-f, --file              Specify python index file, ex: main_index.py"
  echo "--no-req                Skip requirement file installation"
  echo "--server                Run the python file in server mode (with 'runserver' argument)"
  echo "-d, --detach            Run the python server in the background"
  echo "rm		        Stop running process, ex: rm [PID]"
  echo ""
}

python_run_in_background() {
  if [ ! -f "$pid_file" ]; then
    echo -e "${RED}[X] ERROR: PID file not found.${NC}"
    exit 1
  fi

  echo -e "${GREEN}[INFO] Running processes:${NC}"
  while IFS= read -r pid; do
    if ps -p $pid > /dev/null; then
      process_info=$(ps -p $pid -o pid,etime,lstart,cmd --no-headers | head -n 1)
      pid=$(echo $process_info | awk '{print $1}')
      port=$(netstat -tulnp 2>/dev/null | grep $pid | awk '{print $4}' | sed 's/.*://')
      etime=$(echo $process_info | awk '{print $2}')
      lstart=$(echo $process_info | awk '{for (i=3; i<=7; i++) printf $i " ";}')
      cmd=$(echo $process_info | awk '{for (i=8; i<=NF; i++) printf $i " ";}')
      
      # Check if the port is empty
      if [ -z "$port" ]; then
        pids=$(ps --ppid $pid -o pid=)
        for child_pid in $pids; do
          child_port=$(sudo netstat -tulnp | grep -w $child_pid | awk '{print $4}' | sed 's/.*://')
          if [ ! -z "$child_port" ]; then
            port=$child_port
            break
          fi
        done
      fi
      
      echo -e "${GREEN}========================================================================${NC}"
      echo -e "${YELLOW}PID: ${pid}${NC}"
      echo -e "${YELLOW}Up Time: ${etime}${NC}"
      echo -e "${YELLOW}Start Time: ${lstart}${NC}"
      echo -e "${YELLOW}Port: ${port}${NC}"
      echo -e "${YELLOW}Command: ${cmd}${NC}"
      echo
    else
      echo -e "${RED}[X] PID $pid is not running.${NC}"
    fi
  done < "$pid_file"
}





 python_stop() {
  local pid_to_stop=$1

  if [ -z "$pid_to_stop" ]; then
    echo -e "${RED}[X] ERROR: PID to stop is not provided.${NC}"
    exit 1
  fi

  if [ ! -f "$pid_file" ]; then
    echo -e "${RED}[X] ERROR: PID file not found.${NC}"
    exit 1
  fi

  if grep -q "^$pid_to_stop$" "$pid_file"; then
    if ps -p $pid_to_stop > /dev/null; then
      kill $pid_to_stop
      if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Successfully stopped PID: $pid_to_stop${NC}"
        # Remove PID from pidfile
        sed -i "/^$pid_to_stop$/d" "$pid_file"
      else
        echo -e "${RED}[X] ERROR: Failed to stop PID: $pid_to_stop${NC}"
      fi
    else
      echo -e "${RED}[X] PID $pid_to_stop is not running.${NC}"
    fi
  else
    echo -e "${RED}[X] PID $pid_to_stop is not found in pidfile.${NC}"
  fi
}

 python_run() {
  set -e

  local req_file="$1"
  local main_file="$2"
  local noReqFile="$3"
  local serverMode="$4"
  local detach="$5"

  handle_error() {
    local error_message="$1"
    echo -e "${RED}[X] ERROR: ${error_message}${NC}"
  }

  if [ "$noReqFile" -eq "0" ]; then
    if ! pip3 install -r "$req_file" 2> >(while read -r line; do handle_error "$line"; done); then
      exit 1
    fi
  fi

  local run_command="python3 $main_file"
  if [ "$serverMode" -eq "1" ]; then
    run_command="$run_command runserver"
  fi

  if [ "$detach" -eq "1" ]; then
    nohup $run_command > >(awk '{print strftime("[%Y-%m-%d %H:%M:%S]"), $0}' >> "$server_file") 2>&1 &
    local pid=$!
    sleep 5
  
    if ps -p $pid > /dev/null; then
      echo $pid >> $pid_file
      echo -e "${GREEN}[✓] Server is running in the background (PID: $pid).${NC}"
      local process_info=$(ps -p $pid -o pid,tty,stat,time,cmd --no-headers | head -n 1)
      echo -e "${YELLOW}[INFO] Process details: ${process_info}${NC}"
    else
      handle_error "Failed to start the server in the background. Please refer to server.log for error message."
      exit 1
    fi
  else
    if ! $run_command 2> >(while read -r line; do handle_error "$line"; done); then
      handle_error "Python script execution failed."
      exit 1
    fi
  fi
}

  
 nginx_delete() {
  local server_name=$1
  local isError=0

  local config_file="/etc/nginx/conf.d/${server_name}.conf"

  if [[ ! -f "$config_file" ]]; then
    echo -e "${RED}[X] ERROR: Configuration file for server name ${server_name} does not exist.${NC}"
    return 1
  fi

  sudo rm "$config_file"
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}[✓] Successfully deleted the configuration file for server name ${server_name}.${NC}"
    sudo systemctl restart nginx
    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}[✓] NGINX reloaded successfully.${NC}"
    else
      echo -e "${RED}[X] ERROR: Failed to reload NGINX. Please check the NGINX status manually.${NC}"
    fi
  else
    echo -e "${RED}[X] ERROR: Failed to delete the configuration file for server name ${server_name}.${NC}"
    return 1
  fi
}
 nginx_run(){
  local folder_name=$1
  local index_file=$2
  local server_name=$3
  local isStatic=$4
  local port=$5
  local device_ip=$(hostname -I | awk '{print $1}')
  
  if [[ "$isStatic" -eq "1" ]]; then
  
    local target_file="/etc/nginx/conf.d/${server_name}.conf"
  
    if [[ ! -d "/var/www/html/${folder_name}" ]]; then
      echo -e "${RED}[X] ERROR: Folder var/www/html/${folder_name} does not exist.${NC}"
      exit 1
    fi
  
    cp "$template_web_static" "$target_file"
  
    sed -i "s|root /var/www/html;|root /var/www/html/${folder_name};|g" "$target_file"
    sed -i "s|index index.html;|index ${index_file};|g" "$target_file"
    sed -i "s|server_name name.com;|server_name ${server_name};|g" "$target_file"
  else
    local target_file="/etc/nginx/conf.d/${server_name}.conf"
    cp "$template_web_proxy" "$target_file"
  
    sed -i "s|proxy_pass http://localhost:port;|proxy_pass http://localhost:${port};|g" "$target_file"
    sed -i "s|server_name name.com;|server_name ${server_name};|g" "$target_file"
  
  fi
  
  echo -e "${GREEN}[✓] NGINX Configuration File is Created.${NC}"
  
 
  echo "${device_ip} ${server_name}" | sudo tee -a /etc/hosts > /dev/null
  echo -e "${GREEN}[✓] Restarting NGINX Service.${NC}"
  systemctl restart nginx.service
  echo -e "${GREEN}[✓] All Done, now you can access your beatiful website.${NC}"
 }
 
 nginx_help() {
    echo "Usage: arthisan nginx [options]"
    echo "Options:"
    echo "  -h, --help           Show this help message and exit"
    echo "  -f, --folder FILE    Requirement file (must not be empty)"
    echo "  -i, --index FILE     HTML main file (must have a .html or .htm extension)"
    echo "  -p, --port	       Specify running port, ex: -p 8000"
    echo "  -s, --server	       Specify server name, ex: -s model.backend"
    echo "  rm   		       Remove nginx configuration, ex nginx rm model.backend"
    echo "  --proxy              Enable proxy mode"
    echo "  --static             Enable static mode"
  }
 
 nginx(){
  local folder=""
  local index_file=""
  local isStatic=1
  local server_name=""
  local port=""

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -h|--help)
        nginx_help
        return 1
        ;;
      -f|--folder)
        folder="$2"
        if [[ -z "$folder" ]]; then
          echo -e "${RED}[X] ERROR : Folder must not be empty.${NC}"
          isError=1
          return 1
        fi
        shift
        ;;
        -p|--port)
        port="$2"
        if [[ -z "$port" ]]; then
          echo -e "${RED}[X] ERROR : Port must not be empty.${NC}"
          isError=1
          return 1
        fi
        shift
        ;;
      -i|--index)
        index_file="$2"
        if [[ -z "$index_file" || ! "$index_file" =~ \.html?$ ]]; then
          echo -e "${RED}[X] ERROR : HTML main file must have a .html or .htm extension.${NC}"
          isError=1
          return 1
        fi
        shift
        ;;
        rm)
        server_name="$2"
        nginx_delete "$server_name"
        shift
        return 1
        ;;
        -s|--server)
        server_name="$2"
        if [[ -z "$server_name" ]]; then
          echo -e "${RED}[X] ERROR : Server name must not be empty.${NC}"
          isError=1
          return 1
        fi
        
        if [[ -f "/etc/nginx/conf.d/${server_name}.conf" ]]; then
          read -p "$(echo -e ${YELLOW}[!] The server name ${server_name} is already used${NC}). Do you want to overwrite the existing configuration file? (y/n): " overwrite
          if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
            echo -e "${RED}[X] ERROR : Operation aborted by user.${NC}"
            return 1
          fi
        fi
        shift
        ;;
      --proxy)
        isStatic=0
        ;;
      --static)
        isStatic=1
        ;;
      *)
        echo -e "${RED}Unknown parameter: $1${NC}"
        isError=1
        return 1
        ;;
    esac
    shift
  done

  if [[ "$isStatic" -eq "1" ]]; then

  if [[ -z "$folder" ]]; then
    echo -e "${RED}[X] ERROR: Folder name parameter (-f, --folder) is missing.${NC}"
    isError=1
    return 1
  fi

  if [[ -z "$index_file" ]]; then
    echo -e "${RED}[X] ERROR: HTML main file parameter (-i, --index) is missing.${NC}"
    isError=1
    return 1
  fi
  
  else
    if [[ -z "$port" ]]; then
      echo -e "${RED}[X] ERROR: Port information (-p, --port) is missing.${NC}"
      isError=1
      return 1
    fi
  fi
  
  if [[ -z "$server_name" ]]; then
    echo -e "${RED}[X] ERROR: Server name parameter (-s, --server) is missing.${NC}"
    isError=1
    return 1
  fi

  if [[ $isError -eq 1 ]]; then
    return 1
  fi
  
  nginx_run "$folder" "$index_file" "$server_name" "$isStatic" "$port"
  
 }

 node_run() {
  set -e

  local main_file="$1"
  local detach="$2"
  local skip="$3"
  
  local run_command="node $main_file"
  
  if [ "$skip" -eq "0" ]; then
    npm i package.json
    
  fi
  
  if [ "$detach" -eq "1" ]; then
    nohup $run_command > >(awk '{print strftime("[%Y-%m-%d %H:%M:%S]"), $0}' >> "$server_file") 2>&1 &
    local pid=$!
    sleep 5
  
    if ps -p $pid > /dev/null; then
      echo $pid >> $pid_file
      echo -e "${GREEN}[✓] Node is running in the background (PID: $pid).${NC}"
    local process_info=$(ps -p $pid -o pid,tty,stat,time,cmd --no-headers | head -n 1)
    echo -e "${YELLOW}[INFO] Process details: ${process_info}${NC}"
    else
      echo -e "${RED}[X] ERROR: Failed to start the server in the background. Please refer to server.log for error message.${NC}"
      exit 1
    fi
    
  fi
  
  
}

node_help() {
    echo "Usage: arthisan node [OPTIONS]"
    echo "Options:"
    echo "  -h, --help             Show this help message and exit"
    echo "  -f, --file FILE        Specify the main Node.js file to run (default: index.js)"
    echo "  -s, --skip		 Skip npm i"
    echo "  rm			 Remove node process, ex rm [PID]"
    echo " "
}


 node(){
 local main_file="index.js"
 local detach=1
 local skip_npmi=0
 
 while [[ "$#" -gt 0 ]]; do
    case $1 in
      -h|--help)
        node_help
        return 1
        ;;
      -f|--file)
        main_file="$2"
        shift
        ;;
        rm)
        server_name="$2"
        python_stop "$server_name"
        shift
        return 1
        ;;
        -s|--skip)
        skip_npmi=1
        shift
        ;;
      *)
        echo -e "${RED}Unknown parameter: $1${NC}"
        isError=1
        return 1
        ;;
    esac
    shift
    done
    node_run "$main_file" "$detach" "$skip_npmi"
}

 python() {
  local req_file="requirements.txt"
  local noReqFile=0
  local serverMode=0
  local detach=0
  local isError=0

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -h|--help)
        python_help
        return 1
        ;;
      -r|--requirement)
        req_file="$2"
        if [[ "${req_file##*.}" != "txt" ]]; then
          echo -e "${RED}[X] ERROR : Requirement file must have a .txt extension.${NC}"
          isError=1
          return 1
        fi
        shift
        ;;
      -f|--file)
        main_file="$2"
        if [[ "${main_file##*.}" != "py" ]]; then
          echo -e "${RED}[X] ERROR : Python main file must have a .py extension.${NC}"
          isError=1
          return 1
        fi
        shift
        ;;
      --no-req)
        noReqFile=1
        ;;
      --server)
        serverMode=1
        ;;
     -d| --detach)
        detach=1
        ;;
       rm)
       python_stop "$2"
       return 1
       shift
       ;;
      *)
        echo -e "${RED}Unknown parameter: $1${NC}"
        isError=1
        return 1
        ;;
    esac
    shift
  done

  if [ "$isError" -eq 0 ]; then
    python_run "$req_file" "$main_file" "$noReqFile" "$serverMode" "$detach"
  fi
 }
 local command=${1:-}

  case $command in
  -v|--version)
    version
    ;;
  -h|--help|'')
    usage
    ;;
  python)
    shift
    python $@
    ;;
  nginx)
  shift
  nginx $@
  ;;
  node)
  shift
  node $@
  ;;
  ps)
  shift
  python_run_in_background
  ;;
  *)
    invalid_command $command
  esac
}
template_web_proxy='/etc/nginx/conf.d/proxy.conf.bak'
template_web_static='/etc/nginx/conf.d/http.conf.bak'
pid_file="/home/hans/Documents/pidfile"
server_file="/home/hans/Documents/server.log"
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'
main $@