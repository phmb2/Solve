//
//  ComplaintService.swift
//  Solve
//
//  Created by Pedro Barbosa on 07/12/21.
//

import Firebase

struct ComplaintService {
    static let shared = ComplaintService()
    
    func uploadComplaint(caption: String, bank: String, type: UploadComplaintConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = ["uid": uid, "caption": caption, "bank": bank, "likes": 0, "retweets": 0, "timestamp": Int(NSDate().timeIntervalSince1970)] as [String: Any]
        
        switch type {
            case .complaint:
                REF_COMPLAINTS.childByAutoId().updateChildValues(values) { (error, ref) in
                    guard let complaintId = ref.key else { return }
                    REF_USER_COMPLAINTS.child(uid).updateChildValues([complaintId: 1], withCompletionBlock: completion)
                }
            case .reply(let complaint):
                values["replyingTo"] = complaint.user.username
                
                REF_COMPLAINT_REPLIES.child(complaint.complaintId).childByAutoId().updateChildValues(values) { (error, ref) in
                    guard let replyKey = ref.key else { return }
                    REF_USER_REPLIES.child(uid).updateChildValues([complaint.complaintId: replyKey], withCompletionBlock: completion)
                }
        }
    }
    
    func fetchComplaints(completion: @escaping([Complaint]) -> Void) {
        var complaints = [Complaint]()

//        guard let currentUid = Auth.auth().currentUser?.uid else { return }

//        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
//            let followingUid = snapshot.key
//
//            REF_USER_COMPLAINTS.child(followingUid).observe(.childAdded) { snapshot in
//                let complaintId = snapshot.key
//
//                self.fetchComplaint(withComplaintId: complaintId) { complaint in
//                    complaints.append(complaint)
//                    completion(complaints)
//                }
//            }
//        }
//
//        REF_USER_COMPLAINTS.child(currentUid).observe(.childAdded) { snapshot in
//            let complaintId = snapshot.key
//
//            self.fetchComplaint(withComplaintId: complaintId) { complaint in
//                complaints.append(complaint)
//                completion(complaints)
//            }
//        }
        
        //completion(complaints)
        
        REF_COMPLAINTS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }

            let complaintId = snapshot.key

            UserService.shared.fetchUser(uid: uid) { user in
                let complaint = Complaint(user: user, complaintId: complaintId, dictionary: dictionary)
                complaints.append(complaint)
                completion(complaints)
            }
        }
    }
    
    func fetchComplaints(forUser user: User, completion: @escaping([Complaint]) -> Void) {
        var complaints = [Complaint]()
        
        REF_USER_COMPLAINTS.child(user.uid).observe(.childAdded) { snapshot in
            let complaintId = snapshot.key
            
            self.fetchComplaint(withComplaintId: complaintId) { complaint in
                complaints.append(complaint)
                completion(complaints)
            }
        }
    }
    
    func fetchComplaint(withComplaintId complaintId: String, completion: @escaping(Complaint) -> Void) {
        REF_COMPLAINTS.child(complaintId).observeSingleEvent(of: .value) { snapshot in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let complaint = Complaint(user: user, complaintId: complaintId, dictionary: dictionary)
                completion(complaint)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Complaint]) -> Void) {
        var replies = [Complaint]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let complaintKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            REF_COMPLAINT_REPLIES.child(complaintKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                let replyId = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Complaint(user: user, complaintId: replyId, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forComplaint complaint: Complaint, completion: @escaping([Complaint]) -> Void) {
        var complaints = [Complaint]()
        
        REF_COMPLAINT_REPLIES.child(complaint.complaintId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            let complaintId = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let complaint = Complaint(user: user, complaintId: complaintId, dictionary: dictionary)
                complaints.append(complaint)
                completion(complaints)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Complaint]) -> Void) {
        var complaints = [Complaint]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let complaintId = snapshot.key
            self.fetchComplaint(withComplaintId: complaintId) { likedComplaint in
                var complaint = likedComplaint
                complaint.didLike = true
                
                complaints.append(complaint)
                completion(complaints)
            }
        }
    }
    
    func likeComplaint(complaint: Complaint, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = complaint.didLike ? complaint.likes - 1 : complaint.likes + 1
        REF_COMPLAINTS.child(complaint.complaintId).child("complaints").setValue(likes)
        
        if complaint.didLike {
            REF_USER_LIKES.child(uid).child(complaint.complaintId).removeValue { (error, ref) in
                REF_COMPLAINT_LIKES.child(complaint.complaintId).removeValue(completionBlock: completion)
            }
        } else {
            REF_USER_LIKES.child(uid).updateChildValues([complaint.complaintId: 1]) { (error, ref) in
                REF_COMPLAINT_LIKES.child(complaint.complaintId).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkUserLikedComplaint(_ complaint: Complaint, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(currentUid).child(complaint.complaintId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}

