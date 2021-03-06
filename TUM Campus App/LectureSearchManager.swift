//
//  LectureSearchManager.swift
//  TUM Campus App
//
//  Created by Mathias Quintero on 12/10/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Alamofire
import SWXMLHash

class LectureSearchManager: SearchManager {
    
    var request: Request?
    
    var main: TumDataManager?
    
    var query: String?
    
    func setQuery(_ query: String) {
        self.query = query
    }
    
    required init(mainManager: TumDataManager) {
        main = mainManager
    }
    
    func fetchData(_ handler: @escaping ([DataElement]) -> ()) {
        request?.cancel()
        let url = getURL()
        request = Alamofire.request(url).responseString() { (response) in
            if let value = response.result.value {
                let parsedXML = SWXMLHash.parse(value)
                let rows = parsedXML["rowset"]["row"].all
                var lectures = [DataElement]()
                for row in rows {
                    if let name = row["stp_sp_titel"].element?.text, let id = row["stp_sp_nr"].element?.text, let swsString = row["stp_sp_sst"].element?.text, let lectureID = row["stp_lv_nr"].element?.text, let sws = Int(swsString), let semester = row["semester_name"].element?.text, let chair = row["org_name_betreut"].element?.text, let contributors = row["vortragende_mitwirkende"].element?.text, let type = row["stp_lv_art_name"].element?.text {
                        let newLecture = Lecture(id: id, lectureID: lectureID, module: "", name: name, semester: semester, sws: sws, chair: chair, contributors: contributors, type: type)
                        lectures.append(newLecture)
                    }
                }
                handler(lectures)
            }
        }
    }
    
    func getIDForUser(_ name: String) {
        
    }
    
    func getURL() -> String {
        let base = TUMOnlineWebServices.BaseUrl.rawValue + TUMOnlineWebServices.LectureSearch.rawValue
        if let token = main?.getToken(), let search = query {
            let url = base + "?" + TUMOnlineWebServices.TokenParameter.rawValue + "=" + token + "&pSuche=" + search
            
            if let value = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
                return value
            }
        }
        return ""
    }

}
