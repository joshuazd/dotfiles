# Formatting constants
export BOLD=`tput bold`
export UNDERLINE_ON=`tput smul`
export UNDERLINE_OFF=`tput rmul`
export TEXT_BLACK=`tput setaf 0`
export TEXT_RED=`tput setaf 1`
export TEXT_GREEN=`tput setaf 10`
export TEXT_YELLOW=`tput setaf 11`
export TEXT_BLUE=`tput setaf 12`
export TEXT_MAGENTA=`tput setaf 5`
export TEXT_CYAN=`tput setaf 6`
export TEXT_WHITE=`tput setaf 7`
export RESET_FORMATTING=`tput sgr0`
 
# Wrapper function for Maven's mvn command.
function mvnc()
{
  # Filter mvn output using sed
  mvn $@ | sed -e "s/\(\[INFO\].* SUCCESS.*\)/${TEXT_GREEN}${BOLD}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[INFO\].* FAILURE.*\)/${TEXT_RED}${BOLD}\1${RESET_FORMATTING}/g" \
               -e "/SUCCESS/b; /FAILURE/b; s/\(\[INFO\]\)\(.*\)/${TEXT_BLUE}${BOLD}\1${RESET_FORMATTING}\2/g" \
               -e "s/\(\[WARNING\]\)\(.*\)/${BOLD}${TEXT_YELLOW}\1\2${RESET_FORMATTING}/g" \
               -e "s/\(\[ERROR\]\)\(.*\)/${BOLD}${TEXT_RED}\1\2${RESET_FORMATTING}/g" \
               -e "s/Tests run: \([^,]*\), Failures: \([^,]*\), Errors: \([^,]*\), Skipped: \([^,]*\)/${BOLD}${TEXT_GREEN}Tests run: \1${RESET_FORMATTING}, Failures: ${BOLD}${TEXT_RED}\2${RESET_FORMATTING}, Errors: ${BOLD}${TEXT_RED}\3${RESET_FORMATTING}, Skipped: ${BOLD}${TEXT_YELLOW}\4${RESET_FORMATTING}/g"
  # Make sure formatting is reset
  echo -ne ${RESET_FORMATTING}
}
 
# Override the mvn command with the colorized one.
#alias mvn="mvn-color"
