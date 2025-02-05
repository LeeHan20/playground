import SwiftUI

// MARK: - 데이터 모델 정의

/// 팀 내 사용자 정보 (프로필)
struct User: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var school: String
    var department: String
    var role: Role
    var numberOfGroup: Int  // (필요 시 업데이트할 수 있지만 여기서는 teams.count로 표시)
}

enum Role {
    case chairman   // 회장
    case member     // 일반 팀원
}

/// 회의 참석 여부 기록
struct AttendanceRecord: Identifiable, Equatable {
    let id = UUID()
    var user: User
    var isAttending: Bool        // true: 참여, false: 불참
    var absenceReason: String    // 불참 시 사유 (빈 문자열이면 미작성)
}

/// 회의 모델 (회의 생성 시 팀 구성원 전체에 대한 참석 기록을 초기화)
struct Meeting: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var attendanceRecords: [AttendanceRecord] = []
}

/// 팀 모델 (팀 생성 시 고유 초대 코드를 자동 생성)
struct Team: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var chairman: User
    var members: [User]
    var meetings: [Meeting] = []
    var invitationCode: String
}

// MARK: - ContentView (메인 메뉴)
struct ContentView: View {
    // 현재 사용자 프로필
    @State private var currentUser = User(name: "", school: "", department: "", role: .member, numberOfGroup: 0)
    // 사용자가 가입한 팀들을 배열로 관리 (한 사람이 여러 팀에 속할 수 있음)
    @State private var teams: [Team] = []
    // 프로필 설정 화면 표시 여부 (최초 실행 시)
    @State private var isProfileSetupPresented = true

    var body: some View {
        NavigationView {
            List {
                // 첫 번째 섹션: 내 프로필
                Section(header: Text("내 프로필")) {
                    NavigationLink("내 프로필", destination: MyProfileView(currentUser: $currentUser, teams: teams))
                }
                // 두 번째 섹션: 팀 관리
                Section(header: Text("팀 관리")) {
                    NavigationLink("내 팀 목록", destination: MyTeamsView(teams: $teams, currentUser: currentUser))
//                        teams.isEmpty ?
//                        AnyView(
//                            Text("아직 팀이 없습니다.\n팀 만들기 또는 팀 참석하기를 선택하세요.")
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(.gray)
//                                .padding()
//                        )
//                        : AnyView(MyTeamsView(teams: $teams, currentUser: currentUser))
//                    )
                    NavigationLink("팀 만들기", destination: CreateTeamView(teams: $teams, currentUser: $currentUser))
                    NavigationLink("팀 참석하기", destination: JoinTeamView(teams: $teams, currentUser: currentUser))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("메인 메뉴")
        }
        .onAppear {
            // 프로필 정보가 비어있으면 프로필 설정 화면 표시
            if currentUser.name.isEmpty || currentUser.school.isEmpty || currentUser.department.isEmpty {
                isProfileSetupPresented = true
            }
        }
        .sheet(isPresented: $isProfileSetupPresented) {
            ProfileSetupView(currentUser: $currentUser, isPresented: $isProfileSetupPresented)
        }
    }
}

// MARK: - 프로필 설정 화면 (최초 설정)
struct ProfileSetupView: View {
    @Binding var currentUser: User
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var school: String = ""
    @State private var department: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로필 설정")) {
                    TextField("이름", text: $name)
                    TextField("학교", text: $school)
                    TextField("학과", text: $department)
                }
            }
            .navigationTitle("내 프로필 설정")
            .navigationBarItems(trailing: Button("저장") {
                guard !name.isEmpty, !school.isEmpty, !department.isEmpty else { return }
                currentUser.name = name
                currentUser.school = school
                currentUser.department = department
                isPresented = false
            })
        }
    }
}

// MARK: - 내 프로필 화면 (참여 그룹 수 표시 포함)
struct MyProfileView: View {
    @Binding var currentUser: User
    var teams: [Team]
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 100, height: 100)
            Text(currentUser.name)
                .font(.title)
            Text("학교: \(currentUser.school)")
            Text("학과: \(currentUser.department)")
            // 참여한 그룹 수는 teams 배열의 개수로 표시
            Text("참여한 그룹: \(teams.count)개")
                .foregroundColor(.blue)
            Button("프로필 수정") {
                isEditing = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .navigationTitle("내 프로필")
        .sheet(isPresented: $isEditing) {
            EditProfileView(currentUser: $currentUser)
        }
    }
}

// 프로필 수정 화면 (기존 값으로 초기화)
struct EditProfileView: View {
    @Binding var currentUser: User
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var school: String
    @State private var department: String

    init(currentUser: Binding<User>) {
        self._currentUser = currentUser
        _name = State(initialValue: currentUser.wrappedValue.name)
        _school = State(initialValue: currentUser.wrappedValue.school)
        _department = State(initialValue: currentUser.wrappedValue.department)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로필 수정")) {
                    TextField("이름", text: $name)
                    TextField("학교", text: $school)
                    TextField("학과", text: $department)
                }
            }
            .navigationTitle("프로필 수정")
            .navigationBarItems(trailing: Button("저장") {
                guard !name.isEmpty, !school.isEmpty, !department.isEmpty else { return }
                currentUser.name = name
                currentUser.school = school
                currentUser.department = department
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - 내 팀 목록 화면
struct MyTeamsView: View {
    @Binding var teams: [Team]
    var currentUser: User
    
    var body: some View {
        VStack {
            if teams.isEmpty {
                Text("아직 팀이 없습니다.\n팀 만들기 또는 팀 참석하기를 선택하세요.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding()
                    .navigationTitle("내 팀 목록")
            } else {
                List {
                    ForEach(teams) { team in
                        NavigationLink(destination: TeamHomeView(team: binding(for: team), currentUser: currentUser)) {
                            VStack(alignment: .leading) {
                                Text(team.name)
                                    .font(.headline)
                                Text("초대 코드: \(team.invitationCode)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("내 팀 목록")
            }
        }
    }
    
    // teams 배열에서 해당 팀의 binding을 안전하게 반환
    private func binding(for team: Team) -> Binding<Team> {
        guard let index = teams.firstIndex(where: { $0.id == team.id }) else {
            fatalError("Team not found")
        }
        return $teams[index]
    }
}

// MARK: - 팀 만들기 화면
struct CreateTeamView: View {
    @Binding var teams: [Team]
    @Binding var currentUser: User
    @State private var teamName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("새 팀을 만듭니다")
                .font(.headline)
            TextField("팀 이름을 입력하세요", text: $teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("팀 만들기") {
                createTeam()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(teamName.isEmpty ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
        .padding()
        .navigationTitle("팀 만들기")
    }
    
    private func createTeam() {
        guard !teamName.isEmpty else { return }
        // 팀 생성 시 현재 사용자를 회장으로 지정
        currentUser.role = .chairman
        let invitationCode = String(UUID().uuidString.prefix(6)).uppercased()
        let newTeam = Team(name: teamName, chairman: currentUser, members: [currentUser], invitationCode: invitationCode)
        teams.append(newTeam)
    }
}

// MARK: - 팀 참석하기 화면
struct JoinTeamView: View {
    @Binding var teams: [Team]
    var currentUser: User
    @State private var invitationCode: String = ""
    @State private var joinMessage: String = ""
    
    // 예시용 더미 팀 (실제 앱에서는 초대 코드로 서버나 DB에서 팀 정보를 조회)
    var dummyTeam: Team {
        let dummyChairman = User(name: "Chairman", school: "Dummy University", department: "Dummy Dept", role: .chairman, numberOfGroup: 0)
        return Team(name: "Dummy Team", chairman: dummyChairman, members: [dummyChairman], invitationCode: "ABC123")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("팀 초대 코드를 입력하세요")
                .font(.headline)
            TextField("초대 코드", text: $invitationCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("팀 참석하기") {
                joinTeam()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(invitationCode.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Text(joinMessage)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .navigationTitle("팀 참석하기")
    }
    
    private func joinTeam() {
        if invitationCode.uppercased() == dummyTeam.invitationCode {
            var updatedTeam = dummyTeam
            if !updatedTeam.members.contains(where: { $0.id == currentUser.id }) {
                updatedTeam.members.append(currentUser)
            }
            teams.append(updatedTeam)
            joinMessage = "팀에 성공적으로 참석했습니다!"
        } else {
            joinMessage = "유효하지 않은 초대 코드입니다."
        }
    }
}

// MARK: - 팀 홈 화면 (내 팀)
struct TeamHomeView: View {
    @Binding var team: Team
    var currentUser: User
    @State private var showingAddMeeting = false
    @State private var showingParticipants = false
    
    var body: some View {
        VStack {
            if team.meetings.isEmpty {
                Text("아직 회의가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach($team.meetings) { $meeting in
                        NavigationLink(destination: MeetingDetailView(meeting: $meeting, currentUser: currentUser)) {
                            VStack(alignment: .leading) {
                                Text(meeting.title)
                                    .font(.headline)
                                Text("\(meeting.date, formatter: DateFormatter.shortDate)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            if currentUser == team.chairman {
                Button("새로운 회의 추가") {
                    showingAddMeeting = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom)
                .sheet(isPresented: $showingAddMeeting) {
                    AddMeetingView(team: $team)
                }
            }
        }
        .navigationTitle(team.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingParticipants = true
                }) {
                    Image(systemName: "person.3.fill")
                }
                .sheet(isPresented: $showingParticipants) {
                    ParticipantsView(team: team)
                }
            }
        }
    }
}

// MARK: - 참여자 보기 화면
struct ParticipantsView: View {
    var team: Team
    
    var body: some View {
        NavigationView {
            List(team.members) { member in
                NavigationLink(destination: ProfileDetailView(user: member)) {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .font(.headline)
                            Text(member.school)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("참여자 목록")
        }
    }
}

// MARK: - 프로필 상세 화면
struct ProfileDetailView: View {
    var user: User
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 100, height: 100)
            Text(user.name)
                .font(.title)
            Text("학교: \(user.school)")
            Text("학과: \(user.department)")
            if user.role == .chairman {
                Text("역할: 회장")
                    .foregroundColor(.blue)
            } else {
                Text("역할: 팀원")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("프로필")
    }
}

// MARK: - 회의 추가 화면
struct AddMeetingView: View {
    @Binding var team: Team
    @Environment(\.presentationMode) var presentationMode
    @State private var meetingTitle: String = ""
    @State private var meetingDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("회의 정보")) {
                    TextField("회의 제목", text: $meetingTitle)
                    DatePicker("회의 날짜", selection: $meetingDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("새 회의 추가")
            .navigationBarItems(leading: Button("취소") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("저장") {
                addMeeting()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addMeeting() {
        guard !meetingTitle.isEmpty else { return }
        let attendanceRecords = team.members.map { member in
            AttendanceRecord(user: member, isAttending: false, absenceReason: "")
        }
        let newMeeting = Meeting(title: meetingTitle, date: meetingDate, attendanceRecords: attendanceRecords)
        team.meetings.append(newMeeting)
    }
}

// MARK: - 회의 상세 화면
struct MeetingDetailView: View {
    @Binding var meeting: Meeting
    var currentUser: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(meeting.title)
                .font(.title)
            Text("\(meeting.date, formatter: DateFormatter.shortDate)")
                .font(.subheadline)
            Divider()
            Text("참여 여부")
                .font(.headline)
            if meeting.attendanceRecords.isEmpty {
                Text("참여 정보가 없습니다.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(meeting.attendanceRecords) { record in
                        if record.user.id == currentUser.id {
                            NavigationLink(destination: EditAttendanceView(record: binding(for: record))) {
                                AttendanceRow(record: record)
                            }
                        } else {
                            AttendanceRow(record: record)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("회의 상세")
    }
    
    private func binding(for record: AttendanceRecord) -> Binding<AttendanceRecord> {
        guard let index = meeting.attendanceRecords.firstIndex(where: { $0.id == record.id }) else {
            fatalError("AttendanceRecord not found")
        }
        return $meeting.attendanceRecords[index]
    }
}

// MARK: - 참석 여부 행
struct AttendanceRow: View {
    var record: AttendanceRecord
    
    var body: some View {
        HStack {
            Text(record.user.name)
            Spacer()
            if record.isAttending {
                Text("참여")
                    .foregroundColor(.green)
            } else {
                VStack(alignment: .trailing) {
                    Text("불참")
                        .foregroundColor(.red)
                    if !record.absenceReason.isEmpty {
                        Text(record.absenceReason)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - 참석 기록 수정 화면
struct EditAttendanceView: View {
    @Binding var record: AttendanceRecord
    @Environment(\.presentationMode) var presentationMode
    @State private var isAttending: Bool
    @State private var absenceReason: String

    init(record: Binding<AttendanceRecord>) {
        _record = record
        _isAttending = State(initialValue: record.wrappedValue.isAttending)
        _absenceReason = State(initialValue: record.wrappedValue.absenceReason)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("참여 여부")) {
                    Toggle(isOn: $isAttending) {
                        Text(isAttending ? "참여" : "불참")
                    }
                }
                if !isAttending {
                    Section(header: Text("불참 사유 (한 줄 제한)")) {
                        TextField("불참 사유", text: $absenceReason)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("참여 정보 수정")
            .navigationBarItems(trailing: Button("저장") {
                saveChanges()
            })
        }
    }
    
    private func saveChanges() {
        record.isAttending = isAttending
        record.absenceReason = isAttending ? "" : absenceReason
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - 날짜 포맷터 헬퍼
extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
