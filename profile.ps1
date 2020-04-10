function ggs {& git status $args}
function gga {& git add $args}
function ggaa {& git add *}
function ggc {& git commit -m $args}
function ggck {& git checkout $args}
function ggst {& git stash $args}
function ggstp {& git stash pop $args}
function ggp {& git push $args}
function ggpom {& git pull origin master}
function nsl {nslookup $args}
function fdns {ipconfig /flushdns}
function get-weather {(curl http://wttr.in).ParsedHtml.body.outerText}
function update-profile {import-module $profile}
New-Alias -Name "grep" -Value Select-String
New-Alias -Name "Dicker" -Value Docker
New-Alias -Name "Digger" -Value Docker
New-Alias -Name "Dogger" -Value Docker

function Maintain {
    param(
        [String]
        $project
    )
    & "C:\users\teran.selin\git\$project.code-workspace"
}

$bgdc = @'
,-\__\
|f-"Y\|
\()7L/
 cgD                             __ _
 |\(        _______________    .'  Y '>,
  \ \     /                 \ / _   _   \
   \\\   | BE GAY DO CRIMES | )(_) (_)(|}
    \\\   \_______________  / {  4A   } /
     \\\                  \|  \uLuJJ/\l
      \\\                     |3    p)/
       \\\___ __________      /nnm_n//
       c7___-__,__-)\,__)(".  \_>-<_/D
                     \_"-._.__G G_c__.-__<"/ ( \
                         <"-._>__-,G_.___)\   \7\
                        ("-.__.| \"<.__.-" )   \ \
                        |"-.__"\  |"-.__.-".\   \ \
                        ("-.__"". \"-.__.-".|    \_\
                        \"-.__""|!|"-.__.-".)     \ \
                         "-.__""\_|"-.__.-"./      \ l
                          ".__""">G>-.__.-">       .--,_
'@
$bgdc