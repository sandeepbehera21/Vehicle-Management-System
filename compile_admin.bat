@echo off
echo Compiling Admin Management Servlets...

set CATALINA_HOME=C:\Users\sande\Downloads\apache-tomcat-9.0.95
set PROJECT_DIR=C:\Users\sande\Downloads\Vehicle-Management-System-Java-Servlet-main (2)\Vehicle-Management-System-Java-Servlet-main\Vehicle-Management-System-Java-Servlet-main
set CLASSPATH=%CATALINA_HOME%\lib\servlet-api.jar;%PROJECT_DIR%\WebContent\WEB-INF\lib\mysql-connector-java-8.0.28.jar;%PROJECT_DIR%\WebContent\WEB-INF\classes;%PROJECT_DIR%\src

cd /d "%PROJECT_DIR%"

echo Compiling AdminVehiclesServlet...
javac -cp "%CLASSPATH%" -d "WebContent\WEB-INF\classes" src\com\vehicle\AdminVehiclesServlet.java
if %ERRORLEVEL% EQU 0 (
    echo ✓ AdminVehiclesServlet compiled successfully
) else (
    echo ✗ Error compiling AdminVehiclesServlet
)

echo Compiling AdminOwnersServlet...
javac -cp "%CLASSPATH%" -d "WebContent\WEB-INF\classes" src\com\vehicle\AdminOwnersServlet.java
if %ERRORLEVEL% EQU 0 (
    echo ✓ AdminOwnersServlet compiled successfully
) else (
    echo ✗ Error compiling AdminOwnersServlet
)

echo Compiling AdminUsersServlet...
javac -cp "%CLASSPATH%" -d "WebContent\WEB-INF\classes" src\com\vehicle\AdminUsersServlet.java
if %ERRORLEVEL% EQU 0 (
    echo ✓ AdminUsersServlet compiled successfully
) else (
    echo ✗ Error compiling AdminUsersServlet
)

echo.
echo Copying JSP files to deployment directory...
xcopy /Y "WebContent\admin\vehicles.jsp" "%CATALINA_HOME%\webapps\vehicle\admin\"
xcopy /Y "WebContent\admin\owners.jsp" "%CATALINA_HOME%\webapps\vehicle\admin\"
xcopy /Y "WebContent\admin\users.jsp" "%CATALINA_HOME%\webapps\vehicle\admin\"

echo.
echo Copying compiled classes to Tomcat...
if exist "%CATALINA_HOME%\webapps\vehicle\WEB-INF\classes\com\vehicle\" (
    xcopy /Y "WebContent\WEB-INF\classes\com\vehicle\AdminVehiclesServlet.class" "%CATALINA_HOME%\webapps\vehicle\WEB-INF\classes\com\vehicle\"
    xcopy /Y "WebContent\WEB-INF\classes\com\vehicle\AdminOwnersServlet.class" "%CATALINA_HOME%\webapps\vehicle\WEB-INF\classes\com\vehicle\"
    xcopy /Y "WebContent\WEB-INF\classes\com\vehicle\AdminUsersServlet.class" "%CATALINA_HOME%\webapps\vehicle\WEB-INF\classes\com\vehicle\"
    echo ✓ Class files copied to Tomcat
) else (
    echo ✗ Tomcat deployment directory not found. Please deploy the project first.
)

echo.
echo Admin modules compilation completed!
echo You can now access:
echo - Vehicle Management: http://localhost:8080/vehicle/admin/vehicles
echo - Owner Management: http://localhost:8080/vehicle/admin/owners  
echo - User Management: http://localhost:8080/vehicle/admin/users
echo.
pause