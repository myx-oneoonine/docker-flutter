#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) ; pwd -P)
TASK=$1
ARGS=${@:2}

# Docker Flutter specific paths
DOCKER_IMAGE="flutter-dev"
WORKSPACE_PATH="/home/flutter/workspace"
EXAMPLES_DIR=$SCRIPT_DIR/examples/flutter-project

help__init="initialize Docker Flutter development environment and examples"
task__init() {
  echo "🚀 Initializing Docker Flutter development environment..."
  
  # Build the Docker image
  echo "Building Docker image..."
  docker buildx build -t ${DOCKER_IMAGE} .
  
  # Test the environment
  echo "Testing environment..."
  docker run --rm ${DOCKER_IMAGE} whoami || echo "⚠️  Docker test failed"
  
  # Initialize example project if it exists
  if [ -d "${EXAMPLES_DIR}" ]; then
    echo "Initializing example project..."
    make -C ${EXAMPLES_DIR} help
  fi
  
  echo "✅ Docker Flutter environment initialized!"
  echo "💡 Try: ./support.sh shell to start an interactive session"
  echo "💡 Try: ./support.sh examples to work with the example project"
}

help__build="build Docker Flutter image with optional build args"
task__build() {
  echo "🔨 Building Docker Flutter image..."
  docker buildx build -t ${DOCKER_IMAGE} $ARGS .
  echo "✅ Build completed!"
}

help__shell="run interactive shell in Docker Flutter environment"
task__shell() {
  echo "🐚 Starting interactive shell in Docker Flutter environment..."
  docker run -it --rm -v $(pwd):${WORKSPACE_PATH} -w ${WORKSPACE_PATH} ${DOCKER_IMAGE} bash
}

help__flutter="run flutter commands in Docker environment"
task__flutter() {
  echo "🎯 Running flutter $ARGS..."
  docker run --rm -v $(pwd):${WORKSPACE_PATH} -w ${WORKSPACE_PATH} ${DOCKER_IMAGE} flutter $ARGS
}

help__test="run tests for Docker Flutter environment"
task__test() {
  echo "🧪 Running Docker environment tests..."
  if [ -f "./test.sh" ]; then
    ./test.sh
  else
    echo "⚠️  No test.sh found, running basic test..."
    docker run --rm ${DOCKER_IMAGE} echo "Docker container is working!"
  fi
}

help__examples="helper for example Flutter project tasks"
task__examples() {
  if [ -d "${EXAMPLES_DIR}" ]; then
    echo "📁 Running make in examples/flutter-project: $ARGS"
    # Run make commands in Docker environment
    docker run --rm -v ${EXAMPLES_DIR}:${WORKSPACE_PATH} -w ${WORKSPACE_PATH} ${DOCKER_IMAGE} make $ARGS
  else
    echo "⚠️  Examples directory not found at ${EXAMPLES_DIR}"
  fi
}

help__docker="run arbitrary docker commands with the Flutter environment"
task__docker() {
  echo "🐳 Running docker command: $ARGS"
  docker run --rm -v $(pwd):${WORKSPACE_PATH} -w ${WORKSPACE_PATH} ${DOCKER_IMAGE} sh -c "$ARGS"
}

help__clean="clean Docker images and containers"
task__clean() {
  echo "🧹 Cleaning Docker images and containers..."
  docker system prune -f
  docker rmi ${DOCKER_IMAGE} 2>/dev/null || echo "Image ${DOCKER_IMAGE} not found"
  echo "✅ Cleanup completed!"
}

############################################################################

list_all_helps() {
  compgen -v | egrep "^help__.*"
}

HI_BOB() {
  echo "                                                                                                    
                                                +#-..+#                    
                                             #-        #                   
                                           #            #                  
                                         #              -                  
                                +#####--.                #                 
                          -###+--  ---                   #                 
                       ##+-  ---+   --                   +                 
          +###-.    ..  .--  ----.   -                   .+                
       --                --.  ----                        #                
       #                       --.                        #                
       #                        .                          #               
        -                                 #####.            #              
        #                               +#### ##+         .-+#             
         #           .###-              #########       -----#.            
          #         ###. .#.             #######         +##--#            
           #       #########    -##-      .###.       -#+     .#           
            #      -#######+    ###                  -#          #         
            #        #####.       #--#               #           #         
            #                   +#  #                #           +         
            ##--.                                    #           ..        
             # -#####-                               #            +        
             +-        #                             #.           #        
            +.          #                            #.           +        
            # -   #  #  #                            #            --       
      #########+.##.+#-###################################################     
      ${NEW_LINE}"
}

NEW_LINE=$'\n'
if type -t "task__$TASK" &>/dev/null; then
  HI_BOB
  task__$TASK $ARGS
else
  echo "Hi! this is Bob, your best helper for Docker Flutter development 🐳🎯"
  HI_BOB
  echo "usage: $0 <task> [<..args>]"
  echo "task:"

  HELPS=""
  for help in $(list_all_helps)
  do
    HELPS="$HELPS    ${help/help__/} |-- ${!help}${NEW_LINE}"
  done

  echo "$HELPS" | column -t -s "|"
  echo "${NEW_LINE}"
  echo "Examples:"
  echo "  $0 init                    # Initialize environment"
  echo "  $0 shell                   # Start interactive shell"
  echo "  $0 flutter --version       # Check Flutter version"
  echo "  $0 examples init           # Initialize example project"
  echo "  $0 examples gen_all        # Run code generation"
  echo "  $0 docker 'ls -la'         # Run custom commands"
  echo "${NEW_LINE}"
  exit
fi