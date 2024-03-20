FROM ruby:2.7-slim-bullseye
LABEL maintainer="Update by Hasiniaina Andriatsiory <hasiniaina.andriatsiory@gmail.com>"
ENV JAVA_VERSION 11
ENV NODE_VERSION 20
RUN export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip curl build-essential python3 git openjdk-${JAVA_VERSION}-jdk openjdk-${JAVA_VERSION}-jre && \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt install -y nodejs
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64

# Set user to root for necessary permissions
USER root

#Android
# ENV ANDROID_SDK_TOOLS 11076708
# ENV ANDROID_SDK_TOOLS 10406996
ENV ANDROID_SDK_TOOLS 6858069
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
ENV ANDROID_BUILD_TOOLS_VERSION 33.0.0
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_VERSION 33
ENV ANDROID_ARCHITECTURE x86_64
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/platforms:$FLUTTER_HOME/bin:$PATH"

RUN mkdir -p $ANDROID_HOME \
  && mkdir -p /home/$USER/.android \
  && touch /home/$USER/.android/repositories.cfg \
  && curl -o android_tools.zip $ANDROID_SDK_URL \
  && unzip -qq -d "$ANDROID_HOME" android_tools.zip \
  && rm android_tools.zip \
  && mkdir -p $ANDROID_HOME/cmdline-tools/tools \
  && mv $ANDROID_HOME/cmdline-tools/bin $ANDROID_HOME/cmdline-tools/tools \
  && mv $ANDROID_HOME/cmdline-tools/lib $ANDROID_HOME/cmdline-tools/tools \
  && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
  && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" \
  && yes "y" | sdkmanager "platform-tools" \
  && yes "y" | sdkmanager "emulator" \
  && yes "y" | sdkmanager "extras;android;m2repository" \
  && yes "y" | sdkmanager "extras;google;m2repository" \
  && yes "y" | sdkmanager "system-images;android-$ANDROID_VERSION;google_apis_playstore;$ANDROID_ARCHITECTURE"

# Install Gradle
ENV GRADLE_VERSION 8.6
ENV GRADLE_HOME=/usr/local/gradle-${GRADLE_VERSION}
ENV GRADLE_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN cd /usr/local && \
    curl -L  ${GRADLE_URL} -o gradle.zip && \
    unzip gradle.zip && \
    rm gradle.zip
ENV PATH=$PATH:$GRADLE_HOME/bin 

# Install flutter
ENV FLUTTER_URL https://github.com/flutter/flutter.git 
RUN cd /usr/local && \
    git clone $FLUTTER_URL
ENV PATH=$PATH:$FLUTTER_HOME/bin
RUN flutter config --no-analytics --enable-web \
    && flutter precache 
    # && yes "y" | flutter doctor --android-licenses \
    # && flutter doctor \
    # && flutter emulators --create \
    # && flutter update-packages

# Install Fastlane & bundle & rake
RUN gem install rake -NV && \
    gem install fastlane && \
    gem install bundler -v 1.17.2 && \
    gem install screengrab -NV && \
    gem install google-api-client -NV && \
# Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean