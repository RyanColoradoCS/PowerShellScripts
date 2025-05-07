# Define group name here:
$GroupName = "Group-Name-Example"

$users = get-mguser -Filter $GroupName -Property displayname,mail,userprincipalname,givenname,surname,jobtitle | Select-Object displayname,mail,userprincipalname,givenname,surname,jobtitle

foreach ($user in $users) {
    $mail = $user.mail
    $upn = $user.userprincipalname

    set-mailbox $mail -WindowsEmailAddress $upn
    write-host "Setting $upn mail"
}