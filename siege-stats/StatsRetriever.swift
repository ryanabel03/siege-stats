//
//  StatsRetriever.swift
//  siege-stats
//
//  Created by Ryan Abel on 9/25/16.
//  Copyright © 2016 Rabel Products. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON



public class StatsRetriever {
    let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Ubi-AppId": "39baebad-39e5-4552-8c25-2c9b919064e2",
        "Ubi-SessionId": "05fa76e9-3f17-4949-9876-9840489d330d",
        "Authorization": "Ubi_v1 t=eyJ0eXAiOiJKV0UiLCJlbmMiOiJBMTI4Q0JDIiwiaXYiOiJDV0JnRjBPVnZmbTFsLWRsQVJwdGFnIiwiaW50IjoiSFMyNTYiLCJhaWQiOiIzOWJhZWJhZC0zOWU1LTQ1NTItOGMyNS0yYzliOTE5MDY0ZTIiLCJlbnYiOiJQcm9kIiwidmVyIjoiMSIsInNpZCI6IjA1ZmE3NmU5LTNmMTctNDk0OS05ODc2LTk4NDA0ODlkMzMwZCJ9.UpRhNAUbWcyOs2XyiHdE8_AepboPZbTsXhwBk3Egu2OEl95UBa0IzWXFULGo-CJn0gWQsl3xSb8BnWHYTwvpDJFdaIiGdXHZWBXVHusJ6VUtpQ8W3bFagJ-HGiX_k9mpksOk__T-q9iCJvTzdylxNmc9bnvhE1DhDaF8M3MFDnIhAZDkd2fuNhnkCYxhR9gLYeluH1l_iTxUV04l0Dr_invf64mgP3ygzVu3ga2p_eudGxxE_6kuFLNZTXIQUPfj8sxlGoQWPCvTFqpxcJU1k6kvYn2WEeuQ5jd7BP9uzHNRiWuGMAV1koHd9RO0ydn-_fY0jpiJ4Ud1XgIvPMClWRUZBc7K8z35ZRS77hmcQ2o5wUIPx1cVj065W1V0fOaEOXF9CQ4_ZNixkYpBxxV-FXHs4YdJwB38l1-eL8RZVWuQ4sDVRAXlEgyABNbAscazVBroPS17o9A_pdCyOxkmkx1G7vqmd53LgUg4_gfIOP_mtHMe6_f0iAxN8lQm6xBwZAv40mKxx1w_Fnw2qzyxXJIFebBT9yoMcdB9Nqdqxkeg5j_t5BJ6mEHC5SwELfmGFZVTZcdOg2dWDweyOmiHfbkYWokHaiD3qNzCS0dMmGPqzlHNOhjrwJaKpk-sYwVvi17mJSpZUfuIDbxMh3UUyJCF9zdse-sFzyZ6slEWcoHOh3yBpcDxBnrlDvPXaHd523UtkQHAKmYyK65tl16uS3UVhcPaGtu9Qyke2A7gwIFIQ6gOL7N4Z8VftswyVkvRzrg5fogHd1B7WWgOuF0eUTKfwlaFWVQdL5GEooLVHE2LoakutDtw9IC4bfQD6kQX8C715iIds7XzOMGaZXkQrzSU5kcSWQAeQ6EmEppJj0nQJERrsdk6gYG9Wce-LI_8PvW8V8mSOPLGgPI_FqSdhHZrgR26F0ycr7XlGAllDBSjA5xc3c68X-zFOI74L5c6T26rcZde_0pJXB7N8zSQIIO3fbEfZFmbHPWSABa9BbCEKvTAVSFAbKr7MmwQWRA9KEJuwefTo5cEjnJLxt8MxLH3dLmtwmxHV9W4A5pNTZl98tjarhy5aNpmjDCIp1mGb1nRpjhFiWPP9nVCtt_Yfbi0xX25N4J_oKfsyjlmuD35bZzcgRH-tYrYu-4-iEC4080ux72uLKr8vZ-7j7xXhQ.Ka7IgAiO7-14NbY8PeuNBaPjzQFckoMgfF66f_kEFLk"
        
    ]
    
    func makeStatsRequest(profile: PlayerProfile) -> Observable<PlayerProfile> {
        let parameters: Parameters = [
            "populations": profile.id,
            "statistics":"casualpvp_kills,casualpvp_death"
        ]
        
        return Observable.create { observer in
            let request = Alamofire.request("https://public-ubiservices.ubi.com/v1/spaces/05bfb3f7-6c21-4c42-be1f-97a33fb5cf66/sandboxes/OSBOR_PS4_LNCH_A/playerstats2/statistics?", method: .get, parameters: parameters, headers: self.headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let profileJSON = json["results"][profile.id]
                    var newProfile = PlayerProfile()
                    newProfile.id = profile.id
                    newProfile.kills = profileJSON["casualpvp_kills:infinite"].intValue
                    observer.on(.next(newProfile))
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }

    func makeProfileRequest() -> Observable<PlayerProfile> {
        let parameters: Parameters = [
            "profile_ids": "724b05e2-ed38-4399-9e4e-64562d17fd99"
            
        ]
        
        return Observable.create { observer in
            let request = Alamofire.request("https://public-ubiservices.ubi.com/v1/spaces/05bfb3f7-6c21-4c42-be1f-97a33fb5cf66/sandboxes/OSBOR_PS4_LNCH_A/r6playerprofile/playerprofile/progressions", method: .get, parameters: parameters, headers: self.headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var profile = PlayerProfile()
                    profile.id = json["player_profiles"][0]["profile_id"].stringValue
                    observer.on(.next(profile))
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
                
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
}
