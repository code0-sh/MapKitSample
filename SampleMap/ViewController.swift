import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lngLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var locationManager: CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    @IBAction func tapStartButton(_ sender: Any) {
        if locationManager != nil { return }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = 100 // 位置情報取得間隔
        locationManager?.requestWhenInUseAuthorization() // 認証リクエスト
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation() // 位置情報を取得開始
        }
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserLocation = true
    }
    @IBAction func tapStopButton(_ sender: Any) {
        guard let manager = locationManager else { return }
        manager.stopUpdatingLocation()
        manager.delegate = nil
        locationManager = nil
        latLabel.text = "latitude: "
        lngLabel.text = "longitude: "
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = false
        mapView.removeAnnotations(mapView.annotations)
    }
    // MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude,
                                                                      longitude: newLocation.coordinate.longitude)
        let latitude = "".appendingFormat("%.4f", location.latitude)
        let longitude = "".appendingFormat("%.4f", location.longitude)
        latLabel.text = "latitude: " + latitude
        lngLabel.text = "longitude: " + longitude
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        annotation.title = "サンプル"
        annotation.subtitle = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    // MARK:- MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "pinAnnotation"
        if let pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            return pinAnnotationView
        }
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        pinAnnotationView.animatesDrop = true // ピンを上から降らせる
        pinAnnotationView.annotation = annotation // 座標、タイトル、サブタイトルを設定する
        pinAnnotationView.canShowCallout = true // 吹き出しを表示可能にする。
        pinAnnotationView.pinTintColor = UIColor.green // ピンの色を変える
        pinAnnotationView.isDraggable = true // ドラッグを可能にする
        return pinAnnotationView
    }
    //ドラッグ＆ドロップ時の呼び出しメソッド
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationViewDragState,
                 fromOldState oldState: MKAnnotationViewDragState) {
        //ピンを離した場合
        if newState == .ending {
            if let annotation = view.annotation as? MKPointAnnotation {
                //ピンのサブタイトルを最新の座標にする。
                annotation.subtitle = "\(Double(annotation.coordinate.latitude)), \(Double(annotation.coordinate.longitude))"
            }
        }
    }
}
