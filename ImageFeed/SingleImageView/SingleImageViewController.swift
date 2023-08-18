//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Владимир Богомолов on 18.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    var imageUrl: URL?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imageUrl = imageUrl else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                UIBlockingProgressHUD.dismiss()
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                scrollView.minimumZoomScale = 0.1
                scrollView.maximumZoomScale = 1.25
            case .failure:
                UIBlockingProgressHUD.dismiss()
                assertionFailure("Не удалось загрузить изображение")
                return
            }
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView // Нужен ли здесь return?
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        guard let imageView = imageView else { return }
        let imageSize = imageView.frame.size
        let scrollSize = scrollView.bounds.size
        let verticalInset = imageSize.height < scrollSize.height ? (scrollSize.height - imageSize.height) / 2 : 0
        let horizontalInset = imageSize.width < scrollSize.width ? (scrollSize.width - imageSize.width) / 2 : 0
        let contentInset = UIEdgeInsets(top: verticalInset,
                                        left: horizontalInset,
                                        bottom: verticalInset,
                                        right: horizontalInset)
        scrollView.contentInset = contentInset
    }
}
