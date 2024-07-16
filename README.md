# JavaSwitcher-BatFile
Have you ever had 6 versions of Java installed and needed to swap between them quickly on Windows? This might help.

It's a .bat file that updates the User's PATH and System's PATH env variables with a new JDK, updates the JAVA_HOME env variables, swaps out the symbolic links/files in the javapath folder for the selected jdk, and updates the Registry \.jar and \jarfile\shell\open\command keys to get double clicking a .jar in windows explorer working with your newly selected JDK. 

It's commented along to help you trust it, it's hella long because java sucks. ChatGPT and I both agree, if Oracle had any brains or balls, this shit wouldn't suck so much dick. Alas, if you develop android apps, enterprise web servlets, old legacy wsdl projects, and brand spanking new Spring Boot web apps, all simultaneously, you're gonna need something like this. Why? Oh, because Oracle sucks dick, a whole lotta dick.

Run this, restart your command prompt, and bingo, you're a Java master 🧙‍♂️
I recommend adding a folder to your PATH env variable containing this .bat file. Then in a command prompt, simply type java-switch 8 and voila, you're rockin and rollin.
If your versions are different, change the hard coded paths in the file.

Godspeed y'all
