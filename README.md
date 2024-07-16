# JavaSwitcher-BatFile
Have you ever had 6 versions of Java installed and needed to swap between them quickly on Windows? This might help.

It's a simple .bat file that updates the User's PATH and System's PATH env variables with a new JDK, updates the JAVA_HOME env variables, swaps out the symbolic links/files in the javapath folder for the selected jdk, and updates the Registry \.jar and \jarfile\shell\open\command keys to get double clicking a .jar in windows explorer working with your newly selected JDK. 

It's commented along to help you trust it, it's hella long because java sucks and I've never made a .bat file before, chatgpt and I both agree, if Oracle had any brains or balls, this shit wouldn't suck so much dick. Alas, and if you develop android apps, enterprise web servlets, old legacy projects, and brand spanking new Spring Boot web apps, you're gonna need something like this. Why? Oh, because Oracle sucks dick, a whole lotta dick.

Run this, open a new command prompt, and bingo, you're now a Java master 🧙‍♂️

Godspeed y'all
