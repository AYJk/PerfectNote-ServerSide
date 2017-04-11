//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectRequestLogger
import PerfectLogger


let server = HTTPServer()
var routes = Routes()
let myLogger = RequestLogger()

//    MARK: - 添加日志文件记录
let logPath = "./file/log"
let dir = Dir(logPath)
if !dir.exists {
    try Dir(logPath).create()
}
LogFile.location = "\(logPath)/myLog.log" //设置日志文件路径
//  增加日志过滤器，将日志写入响应的文件
server.setRequestFilters([(RequestLogger(),.high)])
server.setResponseFilters([(RequestLogger(),.low)])

//  路由-新增用户
routes.add(method: .get, uri: "/create") { (request, response) in
    response.setHeader(.contentType, value: "text/plain;charset=utf-8")
    guard let userName = request.param(name: "username") else {
        LogFile.error("username参数问题")
        response.setBody(string: "username参数问题")
        response.completed()
        return
    }
    guard let password = request.param(name: "password") else {
        LogFile.error("password参数问题")
        response.setBody(string: "password参数问题")
        response.completed()
        return
    }
    guard let sex = Int(request.param(name: "sex")!) else {
        LogFile.error("sex参数问题")
        response.setBody(string: "sex参数问题")
        response.completed()
        return
    }
    guard let json = UserOperator().insertUserInfo(userName: userName, password: password , sex: sex) else {
        LogFile.error("插入失败，JSON为nil")
        response.setBody(string: "插入失败，JSON为nil")
        response.completed()
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}
//  路由-更新用户
routes.add(method: .get, uri: "/update") { (request, response) in
    response.setHeader(.contentType, value: "text/plain;charset=utf-8")
    guard let userId = request.param(name: "userid") else {
        LogFile.error("userid参数问题")
        response.setBody(string: "userid参数问题")
        response.completed()
        return
    }
    guard let userName = request.param(name: "username") else {
        LogFile.error("username参数问题")
        response.setBody(string: "username参数问题")
        response.completed()
        return
    }
    guard let password = request.param(name: "password") else {
        LogFile.error("password参数问题")
        response.setBody(string: "password参数问题")
        response.completed()
        return
    }
    guard let json = UserOperator().updateUserInfo(userId: userId, password: password, userName: userName) else {
        LogFile.error("更新失败，JSON为nil")
        response.setBody(string: "更新失败，JSON为nil")
        response.completed()
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}
//  路由删除用户
routes.add(method: .get, uri: "/delete") { (request, response) in
    response.setHeader(.contentType, value: "text/plain;charset=utf-8")
    guard let userId = request.param(name: "userid") else {
        LogFile.error("userid参数问题")
        response.setBody(string: "userid参数问题")
        response.completed()
        return
    }
    guard let json = UserOperator().deleteUser(userId: userId) else {
        LogFile.error("删除失败，JSON为nil")
        response.setBody(string: "删除失败，JSON为nil")
        response.completed()
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

routes.add(method: .get, uri: "/search") { (request, response) in
    response.setHeader(.contentType, value: "text/plain;charset=utf-8")
    guard let userName = request.param(name: "username") else {
        LogFile.error("username参数问题")
        response.setBody(string: "username参数问题")
        response.completed()
        return
    }
    guard let password = request.param(name: "password") else {
        LogFile.error("password参数问题")
        response.setBody(string: "password参数问题")
        response.completed()
        return
    }
    guard let json = UserOperator().queryUserInfo(userName: userName, password: password) else {
        LogFile.error("查询失败，JSON为nil")
        response.setBody(string: "查询失败，JSON为nil")
        response.completed()
        return
    }
    LogFile.info(json)
    response.setBody(string: json)
    response.completed()
}

routes.add(method: .get, uri: "/login") { (request, response) in
    response.setHeader(.contentType, value: "text/html;charset=utf-8")
    response.setBody(string: "我是/login路径返回的信息")
    response.completed()
}

routes.add(method: .post, uri: "/user/login") { (request, response) in
    guard let userName = request.param(name: "userName") else {
        return
    }
    guard let password = request.param(name: "password") else {
        return
    }
    let responseDic:[String : Any] = ["data":["userName":userName,"password":password],"result":true,"msg":"请求成功"]
    response.setHeader(.contentType, value: "text/plain;charset=utf-8")
    do {
        let json = try responseDic.jsonEncodedString()
        response.setBody(string: json)
    } catch {
        response.setBody(string: "json转换错误")
    }
    response.completed()
}

server.documentRoot = "./ayjkwebroot"
server.serverPort = 8181

//    MARK: - 路由变量
let valueKey = "key"
routes.add(method: .get, uri: "/path1/{\(valueKey)}/detail") { (request, response) in
    response.setHeader(.contentType, value: "text/html;charset=utf-8")
    response.setBody(string: "我是路由变量：\(request.urlVariables[valueKey]!)")
    response.completed()
}

//    MARK: - 通配符
routes.add(method: .get, uri: "/path2/*/detail") { (request, response) in
    response.setHeader(.contentType, value: "text/html;charset=utf-8")
    response.setBody(string: "我是通配符：\(request.path)")
    response.completed()
}

//    MARK: - 结尾通配符
routes.add(method: .get, uri: "/path3/**") { (request, response) in
    response.setHeader(.contentType, value: "text/html;charset=utf-8")
    response.setBody(string: "我是结尾通配符：\(request.urlVariables[routeTrailingWildcardKey]!)")
    response.completed()
}

struct TestHandler: MustachePageHandler { // 所有目标句柄都必须从PageHandler对象继承
    // 以下句柄函数必须在程序中实现
    // 当句柄需要将参数值传入模板时会被系统调用。
    // - 参数 context 上下文环境：类型为MustacheWebEvaluationContext，为程序内读取HTTPRequest请求内容而保存的所有信息
    // - 参数 collector 结果搜集器：类型为MustacheEvaluationOutputCollector，用于调整模板输出。比如一个`defaultEncodingFunc`默认编码函数将被安装用于改变输出结果的编码方式。
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        var values = MustacheEvaluationContext.MapType()
        values["title"] = "Swift 用户"
        /// 等等等等
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}

routes.add(method: .get, uri: "/") { (request, response) in
    let webroot = request.documentRoot
    mustacheRequest(request: request, response: response, handler: TestHandler(), templatePath: webroot + "/index.html")
}

do {
//    优先级：路由变量 > 静态路由 > 通配符路径 > 结尾通配符
    server.addRoutes(routes)
	// Launch the servers based on the configuration data.
	try server.start()
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

