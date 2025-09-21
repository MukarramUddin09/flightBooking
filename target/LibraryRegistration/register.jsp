<!DOCTYPE html>
<html>
<head>
    <title>Passenger Registration</title>
</head>
<body>
    <h2><b>Passenger Registration Form</b></h2>
    <form action="register.jsp" method="post">
        <label>Name:</label>
        <input type="text" name="name" required><br><br>

        <label>Email:</label>
        <input type="email" name="email" required><br><br>

        <label>Password:</label>
        <input type="password" name="password" required><br><br>

        <label>bookclass:</label>
        <input type="text" name="bookclass"><br><br>

        <input type="submit" value="Register">
    </form>

    <%-- Simple JSP to display submitted values --%>
    <%
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String course = request.getParameter("bookclass");
        if (name != null && email != null) {
    %>
        <h3>Registration Successful!</h3>
        <p><b>Name:</b> <%= name %></p>
        <p><b>Email:</b> <%= email %></p>
        <p><b>BookedClass:</b> <%= course %></p>
    <%
        }
    %>
</body>
</html>
