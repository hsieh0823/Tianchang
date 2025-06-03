FROM gitpod/workspace-full

RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /home/gitpod/flutter
ENV PATH="/home/gitpod/flutter/bin:/home/gitpod/flutter/bin/cache/dart-sdk/bin:${PATH}"
