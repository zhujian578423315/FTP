//
//  Sort.swift
//  FTP
//
//  Created by zhujian on 2016/12/26.
//  Copyright © 2016年 seewo. All rights reserved.
//

import Foundation


class SortModel{
    
  private  var numbers = ["一":1,"二":2,"三":3,"四":4,"五":5,"六":6,"七":7,"八":8,"九":9,"十":10,"百":100,"千":1000,"万":10000]
    
    func chineseToNumber(chinese:String)->Int{
        let x = chinese
        var i = 0
        
        var strarray = [String]()
        for y in x.characters{
            if numbers[y.description] != nil{
                strarray.append(y.description)
            }
        }
        
        if !strarray.isEmpty{
            for x in 0..<strarray.count{
                var multiple = 1
                switch strarray[x] {
                case "万":
                    multiple = 10000
                    if x != 0{
                        i += numbers[strarray[x-1]]!*multiple
                    }
                case "千":
                    multiple = 1000
                    if x != 0{
                        i += numbers[strarray[x-1]]!*multiple
                    }
                case "百":
                    multiple = 100
                    if x != 0{
                        i += numbers[strarray[x-1]]!*multiple
                    }
                case "十":
                    multiple = 10
                    if x != 0{
                        i += numbers[strarray[x-1]]!*multiple
                    }else{
                        i += 10
                    }
                default:
                    break
                }
            }
            if strarray.last != "十"{
                i += numbers[strarray.last!]!
            }
        }
        return i
    }
    
    
    
    func compareChineseNumber(chineseNumberArray:[[String]])->[[String]]{
        var x = chineseNumberArray
        
        var squece = [[String]]()
         var squece1 = [[String]]()
        //将需要提取的内容提取出来
        //筛选需要排列的内容
        for c in 0..<x.count {
            var get = false
            let title = x[c][8].components(separatedBy: " ")[0]
            for y in title.characters{
                if get == false{
                    if numbers[y.description] != nil{
                        squece.append(x[c])
                        get = true
                    }
                }
            }
            //如果内容中没有大写数字记录在squece1中
            if get == false{
                squece1.append(x[c])
            }
        }
        
        let c = squece.sorted { (x, y) -> Bool in
            chineseToNumber(chinese: x[8].components(separatedBy: " ")[0]) < chineseToNumber(chinese: y[8].components(separatedBy: " ")[0])
        }
        
//      for c in squece{
//            let a1 = x[x.count - c - 1][8].components(separatedBy: " ")[0]
//            
//            for c1 in 0..<x.count - c{
//                let a2 = x[c1][8].components(separatedBy: " ")[0]
//                if chineseToNumber(chinese: a1) < chineseToNumber(chinese:a2){
//                    var temp = [String]()
//                    temp = x[x.count - c - 1]
//                    x[x.count - c - 1] = x[c1]
//                    x[c1] = temp
//                }
//            }
//        }
        
        
        return c+squece1
    }
    
}
