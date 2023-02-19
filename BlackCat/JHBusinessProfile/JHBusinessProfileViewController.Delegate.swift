//
//  JHBusinessProfileViewController.Delegate.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/02/18.
//

import UIKit

extension JHBusinessProfileViewController: JHBPMulticastDelegate {
    func notifyViewController(editMode: EditMode) {
        editLabel.text = editMode.asStringInTattooEdit()
        bottomView.bookmarkView.isHidden = editMode == .edit
        if editMode == .edit {
            bottomView.setAskingText("삭제")
            bottomView.setAskButtonTag(3)
            bottomView.layoutIfNeeded()
            bottomView.askButton.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(Constant.width * 100)
                $0.centerX.equalToSuperview()
            }
        } else {

            bottomView.askButton.snp.remakeConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.width.equalTo(Constant.width * 251)
            }
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.bottomView.layoutIfNeeded()
        }
    }

    func notifyViewController(selectedIndex: IndexPath, forType: type) {
        viewModel.selectedTattooIndex.accept(selectedIndex.row)
    }

    func notifyContentHeader(indexPath: IndexPath, forType: type) {
        updateEditButtonUI(selectedRow: indexPath.row)
    }

    func notifyContentCell(indexPath: IndexPath?, forType: type) {
        collectionView.scrollToItem(at: IndexPath(row: forType.rawValue, section: 1),
                                    at: .top,
                                    animated: false)

        notifyViewController(offset: 0, didChangeSection: true)
    }

    func notifyViewController(offset: CGFloat, didChangeSection: Bool) {

        if didChangeSection {
            collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else if offset > UIScreen.main.bounds.height / 1000 {
            collectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3) { [weak self] in
                // 위쪽으로 y만큼 당긴다고 생각하기
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 250)
            }
        } else {
            collectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }

    func notifyViewController(currentDeleteProductIndexList: [Int]) {
        viewModel.currentDeleteProductIndexList = currentDeleteProductIndexList
    }
}

extension JHBusinessProfileViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y > 250

        if scrollView.contentOffset.y > 250 {
            notifyViewController(offset: 1, didChangeSection: true)
        }
    }
}

extension JHBusinessProfileViewController: TwoButtonAlertViewDelegate {
    func didTapRightButton(type: TwoButtonAlertType) {
        switch type {
        case .warningDelete(let indexList):
            viewModel.deleteProductTrigger.accept(indexList)
            break
        default: break
        }
        dismiss(animated: true)
    }

    func didTapLeftButton(type: TwoButtonAlertType) {
        dismiss(animated: true)
    }
}
