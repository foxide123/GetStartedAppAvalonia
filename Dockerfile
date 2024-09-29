# Use the arm32v7 .NET runtime for Raspberry Pi compatibility
FROM mcr.microsoft.com/dotnet/runtime:8.0-bookworm-slim-arm32v7 AS base
WORKDIR /app

# Use the arm32v7 .NET SDK for building the project
FROM mcr.microsoft.com/dotnet/sdk:8.0-bookworm-slim-arm32v7 AS build
WORKDIR /src

RUN apt-get update && apt-get install -y \
    libfontconfig1 \
    libfreetype6 \
    libjpeg-dev \
    libpng-dev \
    libglib2.0-dev \
    libgtk-3-0 \
    x11-apps \
    xvfb

# Copy the .csproj and restore dependencies
COPY ["GetStartedApp.csproj", "GetStartedApp/"]
RUN dotnet restore "GetStartedApp/GetStartedApp.csproj"

# Copy the rest of the source code
COPY . "GetStartedApp/"

# Build the project
WORKDIR "/src/GetStartedApp"
RUN dotnet build "GetStartedApp.csproj" -c Release -o /app/build

# Publish the project
FROM build AS publish
RUN dotnet publish "GetStartedApp.csproj" -c Release -o /app/publish

# Final image with only the runtime dependencies
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Set the entrypoint to run the Avalonia app
ENTRYPOINT ["dotnet", "GetStartedApp.dll"]
