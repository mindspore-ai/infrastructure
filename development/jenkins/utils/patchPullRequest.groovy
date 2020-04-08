import groovy.json.JsonSlurper
def addOrRemoveLables(String OWNER, String PROJECT, String PR_NUMBER, String ACCESS_TOKEN, ArrayList ADD_LABELS, ArrayList REMOVE_LABLES) {
	if (!(OWNER?.trim() && PROJECT?.trim() && PR_NUMBER?.trim() && ACCESS_TOKEN?.trim()))  {
    	throw new Exception("any of 'OWNER', 'PROJECT', 'PR_NUMBER', 'ACCESS_TOKEN' should not be empty")
	}
	//获取PR的详细信息
	def requestUrl = sprintf("https://gitee.com/api/v5/repos/%s/%s/pulls/%s?access_token=%s", OWNER, PROJECT, PR_NUMBER, ACCESS_TOKEN)
    def response = httpRequest quiet: true, consoleLogResponseBody: false,
    						   contentType: 'APPLICATION_JSON',
    						   customHeaders: [[name: "User-Agent", value: "MindSpore"]],
    						   httpMode: 'GET',
    						   url: requestUrl,
    						   ignoreSslErrors: true,
    						   validResponseCodes: "200";
    //解析PR下面现有的标签
    def pullRequest = new JsonSlurper().parseText(response.content)
    def prNames = pullRequest.labels.collect{ it.name }
    println "pr existing labels: $prNames"

    //添加或者移除PR标签
    REMOVE_LABLES.eachWithIndex { v, index ->
     	prNames.remove(v)
    }
    ADD_LABELS.eachWithIndex { v, index ->
	    if (!prNames.contains(v)) {
	    	prNames.add(v)
	     }
    }

    //unset response or will raise exception
    pullRequest = null
    response = null

    //更新PR的标签列表
    def updateUrl = sprintf("https://gitee.com/api/v5/repos/%s/%s/pulls/%s", OWNER, PROJECT, PR_NUMBER)
    def prNameStr = prNames.join(',')
    def updatedLabels = """
    	{"access_token": "$ACCESS_TOKEN", "labels": "$prNameStr"}
    """
    println "going to update pr labels: $prNameStr"
    response = httpRequest quiet: true,
                           acceptType: 'APPLICATION_JSON',
                           consoleLogResponseBody: false,
                           contentType: 'APPLICATION_JSON',
                           requestBody: updatedLabels,
                           customHeaders: [[name: "User-Agent", value: "MindSpore"]],
                           httpMode: 'PATCH',
                           url: updateUrl,
                           validResponseCodes: "200";

    //unset response or will raise exception
    response = null
}
