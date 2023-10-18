#!/bin/bash

declare -A options
options["gateway"]=0
options["Web-gateway"]=0
options["registration"]=0
options["business"]=0
options["security"]=0
options["release"]=0

if [ -z "$1" ]; then
  echo "Usage: $0 [parameter]"
  exit 1
fi

for arg in "$@"; do
  case $arg in
    "gateway")
      options["gateway"]=1
      ;;
     "Web-gateway")
      options["Web-gateway"]=1
      ;;
    "registration")
      options["registration"]=1
      ;;
    "business")
      options["business"]=1
      ;;
      "security")
      options["security"]=1
      ;;
    "release")
      options["release"]=1
      ;;
    *)
      echo "Invalid argument: $arg"
      exit 1
      ;;
  esac
done

if docker network inspect business-live &>/dev/null; then
    echo "Docker network 'business-live' already exists. Skipping creation.."
else
    docker network create business-live
fi

if docker inspect business-redis &>/dev/null; then
    echo "business-redis' already exists. Skipping creation."
else
    echo "Pulling the 'redis' image..."
    docker run -d redis
    echo "Creating the 'business-redis' container..."
    docker run --name business-redis --network business-live -dp 6379:6379 redis
    echo "Successfully created 'business-redis' Container."
fi

echo "Cloning the code"
Doc="$HOME/Documents"

rm -rf BusinessLIVE
# fake url
git clone https://github.com/ayat93aa/BusinessLIVE.git


echo "Start deployment"
if [ ${options["Web-gateway"]} -eq 1 ] || [ ${options["release"]} -eq 1 ]; then
   cd $Doc/BusinessLIVE/WebGateway
    dotnet publish --os linux --arch x64 /t:PublishContainer -c Release
    docker-compose -f Live.yml up -d
fi
if [ ${options["gateway"]} -eq 1 ] || [ ${options["release"]} -eq 1 ]; then
   cd $Doc/BusinessLIVE/MobileGateway
    dotnet publish --os linux --arch x64 /t:PublishContainer -c Release
    docker-compose -f Live.yml up -d
fi
if [ ${options["registration"]} -eq 1 ] || [ ${options["release"]} -eq 1 ]; then
    cd $Doc/BusinessLIVE/Registration
    dotnet publish --os linux --arch x64 /t:PublishContainer -c Release
    docker-compose -f Live.yml up -d
fi
if [ ${options["security"]} -eq 1 ] || [ ${options["release"]} -eq 1 ]; then
    cd $Doc/BusinessLIVE/BusinessSecurity
    dotnet publish --os linux --arch x64 /t:PublishContainer -c Release
    docker-compose -f Live.yml up -d
fi
if [ ${options["Business"]} -eq 1 ] || [ ${options["release"]} -eq 1 ]; then
    cd $Doc/BusinessLIVE/Business
    dotnet publish --os linux --arch x64 /t:PublishContainer -c Release
    docker-compose -f Live.yml up -d

    echo "Executing additional commands inside the container..."
    echo "there is a library need a specific font ... Add it from the hosting machine"
    docker exec -it business-live-business /bin/bash -c "apt-get update && apt-get install -y fontconfig && mkdir -p /usr/share/fonts/truetype/custom" 
    docker stop business-live-business
    docker cp /usr/share/fonts/truetype/custom business-live-business:/usr/share/fonts/truetype/custom/
    docker start business-live-business
fi

echo "Deployement is completed"
cd ../..
rm -rf BusinessLIVE
