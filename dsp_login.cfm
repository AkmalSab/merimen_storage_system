<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Project assessment">
    <meta name="author" content="akmal.sabri@merimen.com">
    <title>Merimen Storage System</title>

    <!--- Bootstrap core CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <cfinclude  template="act_mrmframework.cfm">
  </head>
    <body bgcolor="#C2D514" class="text-center">
        <main class="h-100 d-flex align-items-center justify-content-center">
            <form action="#" method="POST" class="row" id="testform" name="testform">
                <h1 class="h3 mb-3 fw-normal">Sign In</h1>
                <table border=0 cellpadding=3 width=100%>
                    <tr>
                        <td class=clsField1><label for="UserID" class="form-label">User ID:</label></td>
                        <td class=clsValue1><input type=text class="form-control" id="UserID" name="UserID" onblur="chkLoginName(this);DoReq(this);" CHKREQUIRED></td>
                    </tr>
                    <tr>
                        <td class=clsField1><label for="UserPassword" class="form-label">Password:</label></td>
                        <td class=clsValue1><input type=password class="form-control" id="UserPassword" name="UserPassword" onblur="DoReq(this)" CHKREQUIRED></td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type=button value="TEST SUBMIT" onclick="if (FormVerify(document.all('testform'))) alert('Everything OK');" class="col-12 btn btn-primary">
                        </td>
                    </tr>
                </table>
            </form>
        </main>

        <!--- Bootstrap Javascript --->
        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>
    </body>
</html>

