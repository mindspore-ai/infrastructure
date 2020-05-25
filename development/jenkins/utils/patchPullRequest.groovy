def addOrRemoveLables(String OWNER, String PROJECT, String PR_NUMBER, String ACCESS_TOKEN, ArrayList ADD_LABELS, ArrayList REMOVE_LABLES) {
	if (!(OWNER?.trim() && PROJECT?.trim() && PR_NUMBER?.trim() && ACCESS_TOKEN?.trim()))  {
    	throw new Exception("any of 'OWNER', 'PROJECT', 'PR_NUMBER', 'ACCESS_TOKEN' should not be empty")
	}
  try {
    println "going to update pr $OWNER, $PROJECT, $PR_NUMBER,$ADD_LABELS,$REMOVE_LABLES"
    //删除PR的标签
    REMOVE_LABLES.eachWithIndex { v, index ->
      def requestUrl = sprintf("https://gitee.com/api/v5/repos/%s/%s/pulls/%s/labels/%s?access_token=%s", OWNER, PROJECT, PR_NUMBER, v, ACCESS_TOKEN)
      println requestUrl
      def response = httpRequest quiet: true, consoleLogResponseBody: false,
                     contentType: 'APPLICATION_JSON',
                     customHeaders: [[name: "User-Agent", value: "MindSpore"]],
                     httpMode: 'DELETE',
                     url: requestUrl,
                     ignoreSslErrors: true,
                     validResponseCodes: "204,404";
      //unset response or will raise exception
      response = null
    }

    //添加新的标签
    def requestUrl = sprintf("https://gitee.com/api/v5/repos/%s/%s/pulls/%s/labels?access_token=%s", OWNER, PROJECT, PR_NUMBER, ACCESS_TOKEN)
    def prNameStr = ADD_LABELS.join(',')
    def updatedLabels = """
        ["$prNameStr"]
      """
    println requestUrl
    def response = httpRequest quiet: true, consoleLogResponseBody: false,
                   contentType: 'APPLICATION_JSON',
                   customHeaders: [[name: "User-Agent", value: "MindSpore"]],
                   httpMode: 'POST',
                   requestBody: updatedLabels,
                   url: requestUrl,
                   ignoreSslErrors: true,
                   validResponseCodes: "201";
    //unset response or will raise exception
    response = null
  }catch(Exception ex){
    println "failed to update pr $OWNER, $PROJECT, $PR_NUMBER,$ADD_LABELS,$REMOVE_LABLES, $ex"
  }
}
