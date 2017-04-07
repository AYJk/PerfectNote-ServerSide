//
//  PerfectNoteOperator.swift
//  AYJkNote
//
//  Created by AYJk on 2017/4/7.
//
//

import Foundation
import MySQL
import PerfectLogger

let RequestResultSuccess: String = "SUCCESS"
let RequestResultFaile: String = "FAILE"
let ResultListKey: String = "list"
let ResultKey: String = "result"
let ErrorMessageKey = "errorMessage"
var BaseResponseJSON: [String : Any] = [ResultListKey:[],ResultKey:RequestResultSuccess,ErrorMessageKey:""]
//  操作数据库的基类
class BaseOperator {
    let dataBaseName = "test"
    var mysql: MySQL {
        get {
            return MySQLConnnet.shareInstance(dataBaseName: dataBaseName)
        }
    }
    var responseJSON: [String : Any] = BaseResponseJSON
    
}
//  操作用户相关的数据库
class UserOperator: BaseOperator {
    let userTableName = "user"
    
    /// 插入一位用户
    ///
    /// - Parameters:
    ///   - userName: 用户名
    ///   - password: 密码
    /// - Returns: 用户信息
    func insertUserInfo(userName: String, password: String) -> String? {
        let values = "('\(userName)','\(password)')"
        let statement = "insert into \(userTableName)(username, password) values \(values)"
        LogFile.info("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            LogFile.error("\(statement)插入失败")
            self.responseJSON[ResultKey] = RequestResultFaile
            self.responseJSON[ErrorMessageKey] = "创建\(userName)失败"
            guard let json = try? responseJSON.jsonEncodedString() else {
                return nil
            }
            return json
        } else {
            LogFile.info("插入成功")
            return queryUserInfo(userName: userName,password: password)
        }
    }
    
    /// 删除用户
    ///
    /// - Parameter userId: 用户ID
    /// - Returns: 返回JSON
    func deleteUser(userId: String) -> String? {
        let statement = "delete from \(userTableName) where id = '\(userId)'"
        LogFile.info("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            self.responseJSON[ResultKey] = RequestResultFaile
            self.responseJSON[ErrorMessageKey] = "删除失败"
            LogFile.error("\(statement)删除失败")
        } else {
            LogFile.info("SQL:\(statement)删除成功")
            self.responseJSON[ResultKey] = RequestResultSuccess
        }
        guard let json = try? responseJSON.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
    /// 通过userId修改userName和password
    ///
    /// - Parameters:
    ///   - userId: 用户Id
    ///   - password: 密码
    ///   - userName: 用户名
    /// - Returns: 用户信息
    func updateUserInfo(userId: String, password: String, userName: String) -> String? {
        let statement = "update \(userTableName) set username = '\(userName)', password = '\(password)', create_time = now() where id = '\(userId)'"
        LogFile.info("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            LogFile.error("\(statement)更新失败")
            self.responseJSON[ResultKey] = RequestResultFaile
            self.responseJSON[ErrorMessageKey] = "更新失败"
            guard let json = try? responseJSON.jsonEncodedString() else {
                return nil
            }
            return json
        } else {
            LogFile.info("SQL:\(statement)更新成功")
            return queryUserInfo(userName: userName, password: password)
        }
    }
    
    /// 通过用户名查询用户信息
    ///
    /// - Parameter userName: 用户名
    /// - Returns: 用户信息
    func queryUserInfo(userName: String) -> String? {
        let statement = "select id, username from user where username = '\(userName)'"
        LogFile.info("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            self.responseJSON[ResultKey] = RequestResultFaile
            self.responseJSON[ErrorMessageKey] = "查询失败"
            LogFile.error("\(statement)查询失败")
        } else {
                LogFile.info("SQL:\(statement)查询成功")
        }
        // 在当前会话过程中保存查询结果
        let result = mysql.storeResults()!
        var dic = [String: String]()
        result.forEachRow(callback: { (row) in
        //保存选项表的Name名称字段，应该是所在行的第一列，所以是row[0].
            guard let userId = row.first! else {
                return
            }
            dic["userId"] = "\(userId)"
            dic["userName"] = "\(row[1]!)"
        })
        self.responseJSON[ResultKey] = RequestResultSuccess
        self.responseJSON[ResultListKey] = dic
        guard let json = try? responseJSON.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
    /// 通过用户名和密码查询用户信息
    ///
    /// - Parameters:
    ///   - userName: 用户名
    ///   - password: 密码
    /// - Returns: 用户信息
    func queryUserInfo(userName: String, password: String) -> String? {
        let statement = "select * from user where username = '\(userName)' and password = '\(password)'"
        LogFile.info("执行SQL:\(statement)")
        if !mysql.query(statement: statement) {
            self.responseJSON[ResultKey] = RequestResultFaile
            self.responseJSON[ErrorMessageKey] = "查询失败"
            LogFile.error("\(statement)查询失败")
        } else {
            LogFile.info("SQL:\(statement)查询成功")
            //在会话过程中保存结果
            //因为上一步已经验证查询是成功的，因此这里我们认为结果记录集可以强制转换为期望的数据结果。当然您如果需要也可以用if-let来调整这一段代码。
            let result = mysql.storeResults()!
            var dic = [String: String]()
            if result.numRows() == 0 {
                self.responseJSON[ResultKey] = RequestResultFaile
                self.responseJSON[ErrorMessageKey] = "用户名或密码错误，请重新输入"
                LogFile.error("\(statement)用户名或密码错误，请重新输入")
            } else {
                result.forEachRow(callback: { (row) in
                    guard let userId = row.first! else {
                        return
                    }
                    dic["userId"] = userId
                    dic["userName"] = "\(row[1]!)"
                    dic["password"] = "\(row[2]!)"
                    dic["create_time"] = "\(row[3]!)"
                })
                self.responseJSON[ResultKey] = RequestResultSuccess
                self.responseJSON[ResultListKey] = dic
            }
        }
        guard let json = try? responseJSON.jsonEncodedString() else {
            return nil
        }
        return json
    }
    
//    class ContentOperator: BaseOperator {
//        let contentTableName = "content"
//        
//    }
    
}
