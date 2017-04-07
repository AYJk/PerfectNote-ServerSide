//
//  BaseOperator.swift
//  AYJkNote
//
//  Created by AYJk on 2017/4/7.
//
//

import Foundation
import MySQL
import PerfectLogger

// 连接MySql数据库的类
class MySQLConnnet {
    var host: String {
        get {
            return "127.0.0.1"
        }
    }
    var port: String {
        get {
            return "3306"
        }
    }
    var user: String {
        get {
            return "root"
        }
    }
    var password: String {
        get {
            return "12345678"
        }
    }
    
    private var mysql: MySQL!   //用于操作MySQL句柄
    
    //    MySQL句柄单例
    private static var instance: MySQL!
    public static func shareInstance(dataBaseName: String) -> MySQL {
        if instance == nil {
            instance = MySQLConnnet(dataBaseName: dataBaseName).mysql
        }
        return instance
    }
    
    //    私有构造器
    private init(dataBaseName: String) {
        self.connectDataBase()
        self.selectDataBase(name: dataBaseName)
    }
    
    //    连接数据库
    private func connectDataBase() {
        if mysql == nil {
            mysql = MySQL()
        }
        let connected = mysql.connect(host: "\(host)", user: "\(user)", password: "\(password)")
        guard connected else { //验证链接是否成功
            LogFile.error(mysql.errorMessage())
            return
        }
        LogFile.info("数据库连接成功")
    }
    
    //    选择数据库的Scheme
    func selectDataBase(name: String) {
        guard mysql.selectDatabase(named: name) else {
            LogFile.error("数据库选择错误。错误代码:\(mysql.errorCode()),错误信息:\(mysql.errorMessage())")
            return
        }
        LogFile.info("连接Scheme:\(name)成功")
    }
    
    deinit {
        
    }
}
